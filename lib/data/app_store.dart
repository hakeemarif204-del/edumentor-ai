import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  SharedPreferences? _prefs;
  StreamSubscription<User?>? _authSub;
  Timer? _syncTimer;
  String? _uid;
  bool ready = false;
  String? syncNote;

  String parentName = '';
  String parentEmoji = '🛡️';
  String parentEmail = '';
  String pin = '';
  bool pinIsSet = false;
  bool pinEnabled = true;
  bool soundEnabled = true;
  String language = 'English';
  int dailyMinutes = 30;
  bool breakReminders = true;
  bool sessionLimit = true;
  bool bedtimeRestriction = false;
  int bedtimeHour = 20;
  bool dailyReminder = true;
  Set<String> enabledDays = {...weekDayLabels};
  bool achievementNotifs = true;
  bool progressReports = true;
  bool aiRecommendations = true;

  List<ChildProfile> children = [];
  String activeChildId = '';
  List<ActivityRecord> activities = [];
  List<LearningGoal> goals = [];
  List<AppNote> notes = [];
  Map<String, Map<String, Set<String>>> learned = {};
  Map<String, Map<String, int>> unlocks = {};
  Map<String, Map<String, int>> minutesByDay = {};
  Map<String, Set<String>> badges = {};
  Set<String> celebratedGoals = {};
  String? timeWarnDay;
  String? reminderDay;
  DateTime updatedAt = DateTime.now();

  String get ttsLanguage {
    switch (language) {
      case 'French':
        return 'fr-FR';
      case 'Arabic':
        return 'ar';
      default:
        return 'en-US';
    }
  }

  ChildProfile get activeChild {
    for (final child in children) {
      if (child.id == activeChildId) return child;
    }
    return children.first;
  }

  int get todayMinutes => minutesByDay[activeChild.id]?[dayKey(DateTime.now())] ?? 0;

  int get unreadNotes => notes.where((note) => !note.isRead).length;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    _uid = user?.uid;
    await _loadLocal(_storageKey);
    if (children.isEmpty) _seedChild();
    loadPinGuard();
    ready = true;
    notifyListeners();
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuth);
    if (_uid != null) unawaited(_pullRemote());
    _maybeDailyReminder();
  }

  String get _storageKey => _uid == null ? 'notebook_guest' : 'notebook_$_uid';

  Future<void> _onAuth(User? user) async {
    final next = user?.uid;
    if (next == _uid) {
      if (next != null) await _pullRemote();
      return;
    }
    final guestJson = _uid == null ? toJson() : null;
    final guestHadPlay = _uid == null && activities.isNotEmpty;
    _uid = next;
    await _loadLocal(_storageKey);
    if (children.isEmpty) _seedChild();
    if (next == null) {
      notifyListeners();
      return;
    }
    final remote = await _fetchRemote(next);
    if (remote == null && guestHadPlay && guestJson != null) {
      _apply(guestJson);
      await _pushRemote();
    } else if (remote != null) {
      final remoteAt = DateTime.tryParse(remote['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (remoteAt.isAfter(updatedAt)) {
        _apply(remote);
        await _writeLocal();
      } else {
        await _pushRemote();
      }
    } else {
      await _pushRemote();
    }
    notifyListeners();
  }

  void _seedChild() {
    final child = ChildProfile(
      id: 'child_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Little Learner',
      age: 4,
      avatarEmoji: '🌟',
    );
    children = [child];
    activeChildId = child.id;
  }

  ChildStats statsFor(String childId) {
    final mine = activities.where((item) => item.childId == childId).toList();
    final learnedFor = learned[childId] ?? {};
    int bucket(String key) => learnedFor[key]?.length ?? 0;

    final scores = <String, List<int>>{};
    for (final item in mine) {
      scores.putIfAbsent(item.subject, () => []).add(item.score);
    }
    final subjectScores = <String, double>{};
    scores.forEach((subject, values) {
      final total = values.fold<int>(0, (running, value) => running + value);
      subjectScores[subject] = (total / values.length) / 100;
    });

    const tracked = ['Alphabets', 'Numbers', 'Colours', 'Shapes', 'Rhymes'];
    String strongest = tracked.first;
    String weakest = tracked.first;
    double high = -1;
    double low = 2;
    for (final subject in tracked) {
      final score = subjectScores[subject] ?? 0;
      if (score > high) {
        high = score;
        strongest = subject;
      }
      if (score < low) {
        low = score;
        weakest = subject;
      }
    }

    final ratios = [
      bucket('letters') / 26,
      bucket('numbers') / 10,
      bucket('shapes') / 8,
      bucket('colours') / 8,
    ];
    final overall = ratios.fold<double>(0, (running, value) => running + value) / ratios.length;

    return ChildStats(
      lettersLearned: bucket('letters'),
      numbersLearned: bucket('numbers'),
      shapesLearned: bucket('shapes'),
      coloursLearned: bucket('colours'),
      gamesPlayed: mine.where((item) => item.subject == 'Games').length,
      storiesCompleted: mine.where((item) => item.subject == 'Stories').length,
      rhymesHeard: bucket('rhymes'),
      matchingPlayed: mine.where((item) => item.subject == 'Matching').length,
      activitiesCompleted: mine.length,
      stars: mine.fold<int>(0, (running, item) => running + item.stars),
      streak: _streak(childId),
      overall: overall.clamp(0, 1).toDouble(),
      weekly: _weekly(childId),
      subjectScores: subjectScores,
      strongestSubject: strongest,
      weakestSubject: weakest,
    );
  }

  int _streak(String childId) {
    final days = activities
        .where((item) => item.childId == childId)
        .map((item) => DateTime(item.at.year, item.at.month, item.at.day))
        .toSet();
    if (days.isEmpty) return 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  List<double> _weekly(String childId) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final counts = List<int>.filled(7, 0);
    for (final item in activities.where((entry) => entry.childId == childId)) {
      final day = DateTime(item.at.year, item.at.month, item.at.day);
      final diff = day.difference(monday).inDays;
      if (diff >= 0 && diff < 7) counts[diff]++;
    }
    final maxCount = counts.fold<int>(0, (max, value) => value > max ? value : max);
    if (maxCount == 0) return List<double>.filled(7, 0);
    return counts.map((value) => value / maxCount).toList();
  }

  List<BadgeView> badgesFor(String childId) {
    final stats = statsFor(childId);
    final defs = [
      BadgeView(id: 'first', emoji: '🌟', title: 'First Steps', description: 'Completed a first activity', unlocked: stats.activitiesCompleted >= 1),
      BadgeView(id: 'letters', emoji: '🔤', title: 'Alphabet Explorer', description: 'Learned 10 letters', unlocked: stats.lettersLearned >= 10),
      BadgeView(id: 'numbers', emoji: '🔢', title: 'Number Explorer', description: 'Learned numbers 1–10', unlocked: stats.numbersLearned >= 10),
      BadgeView(id: 'colours', emoji: '🎨', title: 'Colour Champion', description: 'Explored the colours', unlocked: stats.coloursLearned >= 8),
      BadgeView(id: 'shapes', emoji: '🔺', title: 'Shape Superstar', description: 'Mastered 5 shapes', unlocked: stats.shapesLearned >= 5),
      BadgeView(id: 'streak', emoji: '🔥', title: 'Learning Streak', description: '7 consecutive learning days', unlocked: stats.streak >= 7),
      BadgeView(id: 'super', emoji: '🏆', title: 'Super Learner', description: 'Completed 50 activities', unlocked: stats.activitiesCompleted >= 50),
      BadgeView(id: 'rhymes', emoji: '🎵', title: 'Rhyme Time', description: 'Listened to 8 rhymes', unlocked: stats.rhymesHeard >= 8),
      BadgeView(id: 'stories', emoji: '📖', title: 'Story Lover', description: 'Finished 5 stories', unlocked: stats.storiesCompleted >= 5),
      BadgeView(id: 'games', emoji: '🎮', title: 'Game Master', description: 'Played 20 games', unlocked: stats.gamesPlayed >= 20),
      BadgeView(id: 'stars', emoji: '⭐', title: 'Star Collector', description: 'Earned 50 stars', unlocked: stats.stars >= 50),
      BadgeView(id: 'match', emoji: '🧩', title: 'Puzzle Pro', description: 'Completed 10 matching games', unlocked: stats.matchingPlayed >= 10),
    ];
    return defs;
  }

  int unlockLevel(String game) {
    return unlocks[activeChild.id]?[game] ?? 1;
  }

  void setUnlock(String game, int level) {
    final childUnlocks = unlocks.putIfAbsent(activeChild.id, () => {});
    final current = childUnlocks[game] ?? 1;
    if (level <= current) return;
    childUnlocks[game] = level > 10 ? 10 : level;
    _touch();
  }

  void markLearned(String bucket, String item) {
    final sets = learned.putIfAbsent(activeChild.id, () => {});
    final values = sets.putIfAbsent(bucket, () => {});
    if (values.contains(item)) return;
    values.add(item);
    _touch();
  }

  bool hasLearned(String bucket, String item) {
    return learned[activeChild.id]?[bucket]?.contains(item) ?? false;
  }

  void recordActivity({
    required String subject,
    required String title,
    required int score,
    required int stars,
  }) {
    final child = activeChild;
    activities.insert(
      0,
      ActivityRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        childId: child.id,
        subject: subject,
        title: title,
        score: score.clamp(0, 100).toInt(),
        stars: stars.clamp(0, 3).toInt(),
        at: DateTime.now(),
      ),
    );
    if (activities.length > 300) {
      activities = activities.sublist(0, 300);
    }
    if (stars > 0 && achievementNotifs) {
      _addNote('⭐', 'New stars', '${child.name} earned $stars star${stars == 1 ? '' : 's'} in $title.');
    }
    _checkGoals(child);
    _checkBadges(child);
    _maybeAiNote(child);
    _touch();
  }

  void _checkGoals(ChildProfile child) {
    if (!progressReports) return;
    for (final goal in goals.where((item) => item.childId == child.id)) {
      if (goalCurrent(goal) >= goal.target && celebratedGoals.add(goal.id)) {
        _addNote('🎯', 'Goal finished', '${child.name} completed "${goal.title}".');
      }
    }
  }

  void _checkBadges(ChildProfile child) {
    final known = badges.putIfAbsent(child.id, () => {});
    for (final badge in badgesFor(child.id)) {
      if (badge.unlocked && known.add(badge.id) && achievementNotifs) {
        _addNote(badge.emoji, 'Achievement unlocked', '${child.name} earned ${badge.title}.');
      }
    }
  }

  void _maybeAiNote(ChildProfile child) {
    if (!aiRecommendations) return;
    final today = dayKey(DateTime.now());
    final key = 'ai_$today';
    if (celebratedGoals.contains(key)) return;
    celebratedGoals.add(key);
    final stats = statsFor(child.id);
    _addNote('💡', 'AI recommendation', '${child.name} could use a little more ${stats.weakestSubject.toLowerCase()} practice.');
  }

  int goalCurrent(LearningGoal goal) {
    final count = activities.where((item) {
      return item.childId == goal.childId && item.subject == goal.subject && !item.at.isBefore(goal.createdAt);
    }).length;
    if (count > goal.target) return goal.target;
    return count;
  }

  List<LearningGoal> goalsForActive() {
    return goals.where((goal) => goal.childId == activeChild.id).toList();
  }

  void addGoal(LearningGoal goal) {
    goals = [goal, ...goals];
    _touch();
  }

  void updateGoal(LearningGoal goal) {
    goals = [for (final item in goals) item.id == goal.id ? goal : item];
    _touch();
  }

  void deleteGoal(String id) {
    goals = goals.where((goal) => goal.id != id).toList();
    celebratedGoals.remove(id);
    _touch();
  }

  void addChild(ChildProfile child) {
    children = [...children, child];
    activeChildId = child.id;
    _touch();
  }

  void updateChild(ChildProfile child) {
    children = [for (final item in children) item.id == child.id ? child : item];
    _touch();
  }

  void setActiveChild(String id) {
    activeChildId = id;
    _touch();
  }

  void deleteChild(String id) {
    if (children.length <= 1) return;
    children = children.where((child) => child.id != id).toList();
    activities = activities.where((item) => item.childId != id).toList();
    goals = goals.where((goal) => goal.childId != id).toList();
    learned.remove(id);
    unlocks.remove(id);
    minutesByDay.remove(id);
    badges.remove(id);
    if (activeChildId == id) activeChildId = children.first.id;
    _touch();
  }

  String? blockReason() {
    final now = DateTime.now();
    if (!enabledDays.contains(weekdayLabel(now))) {
      return 'Today is a rest day. Learning opens again on a day you turned on in Parent Zone.';
    }
    if (bedtimeRestriction && now.hour >= bedtimeHour) {
      return 'Bedtime has started. Learning opens again tomorrow.';
    }
    if (sessionLimit && todayMinutes >= dailyMinutes) {
      return 'Today\'s learning time is finished. See you tomorrow!';
    }
    return null;
  }

  bool get approachingLimit => sessionLimit && dailyMinutes > 0 && todayMinutes >= (dailyMinutes * 0.8);

  void addMinutes(int minutes) {
    if (minutes <= 0) return;
    final childId = activeChild.id;
    final key = dayKey(DateTime.now());
    final days = minutesByDay.putIfAbsent(childId, () => {});
    final before = days[key] ?? 0;
    days[key] = before + minutes;
    final after = days[key]!;
    if (sessionLimit && progressReports) {
      final warnAt = (dailyMinutes * 0.8).ceil();
      final today = dayKey(DateTime.now());
      if (before < warnAt && after >= warnAt && timeWarnDay != today) {
        timeWarnDay = today;
        _addNote('⏱️', 'Time almost up', '${activeChild.name} has used $after of $dailyMinutes learning minutes.');
      }
      if (before < dailyMinutes && after >= dailyMinutes) {
        _addNote('⏱️', 'Learning time finished', '${activeChild.name} reached today\'s limit.');
      }
    }
    _touch();
  }

  void _maybeDailyReminder() {
    if (!dailyReminder) return;
    final today = dayKey(DateTime.now());
    if (reminderDay == today) return;
    final playedToday = activities.any((item) => item.childId == activeChild.id && dayKey(item.at) == today);
    if (playedToday) return;
    if (DateTime.now().hour < 8) return;
    reminderDay = today;
    _addNote('📚', 'Daily reminder', 'A short activity with ${activeChild.name} keeps the streak going.');
    _touch();
  }

  void setParentName(String value) {
    parentName = value.trim();
    _touch();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && parentName.isNotEmpty) {
      user.updateDisplayName(parentName);
    }
  }

  void setParentEmoji(String emoji) {
    parentEmoji = emoji;
    _touch();
  }

  Future<String?> requestEmailChange(String email) async {
    parentEmail = email.trim();
    _touch();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Sign in from Parent Zone to change the login email.';
    try {
      await user.verifyBeforeUpdateEmail(parentEmail);
      return 'Check $parentEmail to confirm the new login.';
    } on FirebaseAuthException catch (error) {
      return error.message ?? 'The email could not be updated.';
    }
  }

  void setPin(String value) {
    pin = value;
    pinIsSet = value.length == 4;
    _touch();
  }

  void setPinEnabled(bool value) {
    pinEnabled = value;
    _touch();
  }

  void rememberParent({String? name, required String email}) {
    parentEmail = email.trim();
    final trimmedName = name?.trim() ?? '';
    if (trimmedName.isNotEmpty) parentName = trimmedName;
    _touch();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && parentName.isNotEmpty) {
      user.updateDisplayName(parentName);
    }
  }

  DateTime? pinLockedUntil;

  bool get pinIsLocked => pinLockedUntil != null && pinLockedUntil!.isAfter(DateTime.now());

  void loadPinGuard() {
    final until = _prefs?.getInt('parent_pin_lock') ?? 0;
    pinLockedUntil = until == 0 ? null : DateTime.fromMillisecondsSinceEpoch(until);
    if (pinLockedUntil != null && !pinLockedUntil!.isAfter(DateTime.now())) {
      pinLockedUntil = null;
      _prefs?.remove('parent_pin_lock');
    }
  }

  void noteWrongPin() {
    final fails = (_prefs?.getInt('parent_pin_fails') ?? 0) + 1;
    if (fails >= 5) {
      pinLockedUntil = DateTime.now().add(const Duration(seconds: 45));
      _prefs?.setInt('parent_pin_fails', 0);
      _prefs?.setInt('parent_pin_lock', pinLockedUntil!.millisecondsSinceEpoch);
    } else {
      _prefs?.setInt('parent_pin_fails', fails);
    }
    notifyListeners();
  }

  void clearPinFailures() {
    pinLockedUntil = null;
    _prefs?.setInt('parent_pin_fails', 0);
    _prefs?.remove('parent_pin_lock');
    notifyListeners();
  }

  static bool weakPin(String value) {
    if (value.length != 4) return true;
    if (value.split('').toSet().length == 1) return true;
    const easy = {'1234', '4321', '0123', '1212', '2580', '1122', '0000'};
    return easy.contains(value);
  }

  void setSound(bool value) {
    soundEnabled = value;
    _touch();
  }

  void setLanguage(String value) {
    language = value;
    _touch();
  }

  void setDailyMinutes(int value) {
    dailyMinutes = value;
    _touch();
  }

  void toggleDay(String day) {
    if (enabledDays.contains(day)) {
      if (enabledDays.length == 1) return;
      enabledDays.remove(day);
    } else {
      enabledDays.add(day);
    }
    _touch();
  }

  void setBreakReminders(bool value) {
    breakReminders = value;
    _touch();
  }

  void setSessionLimit(bool value) {
    sessionLimit = value;
    _touch();
  }

  void setBedtime(bool value) {
    bedtimeRestriction = value;
    _touch();
  }

  void setDailyReminder(bool value) {
    dailyReminder = value;
    _touch();
  }

  void setAchievementNotifs(bool value) {
    achievementNotifs = value;
    _touch();
  }

  void setProgressReports(bool value) {
    progressReports = value;
    _touch();
  }

  void setAiRecommendations(bool value) {
    aiRecommendations = value;
    _touch();
  }

  void markNoteRead(String id) {
    for (final note in notes) {
      if (note.id == id) note.isRead = true;
    }
    _touch();
  }

  void markAllNotesRead() {
    for (final note in notes) {
      note.isRead = true;
    }
    _touch();
  }

  void deleteNote(String id) {
    notes = notes.where((note) => note.id != id).toList();
    _touch();
  }

  void _addNote(String emoji, String title, String body) {
    notes.insert(
      0,
      AppNote(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        emoji: emoji,
        title: title,
        body: body,
        at: DateTime.now(),
      ),
    );
    if (notes.length > 80) notes = notes.sublist(0, 80);
  }

  void _touch() {
    updatedAt = DateTime.now();
    notifyListeners();
    unawaited(_writeLocal());
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(_pushRemote());
    });
  }

  Future<void> _loadLocal(String key) async {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) {
      _apply(null);
      return;
    }
    try {
      _apply(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _apply(null);
    }
  }

  Future<void> _writeLocal() async {
    await _prefs?.setString(_storageKey, jsonEncode(toJson()));
  }

  Map<String, dynamic> toJson() => {
        'updatedAt': updatedAt.toIso8601String(),
        'parentName': parentName,
        'parentEmoji': parentEmoji,
        'parentEmail': parentEmail,
        'pin': pin,
        'pinIsSet': pinIsSet,
        'pinEnabled': pinEnabled,
        'soundEnabled': soundEnabled,
        'language': language,
        'dailyMinutes': dailyMinutes,
        'breakReminders': breakReminders,
        'sessionLimit': sessionLimit,
        'bedtimeRestriction': bedtimeRestriction,
        'bedtimeHour': bedtimeHour,
        'dailyReminder': dailyReminder,
        'enabledDays': enabledDays.toList(),
        'achievementNotifs': achievementNotifs,
        'progressReports': progressReports,
        'aiRecommendations': aiRecommendations,
        'activeChildId': activeChildId,
        'children': children.map((child) => child.toJson()).toList(),
        'activities': activities.map((item) => item.toJson()).toList(),
        'goals': goals.map((goal) => goal.toJson()).toList(),
        'notes': notes.map((note) => note.toJson()).toList(),
        'learned': learned.map((childId, buckets) => MapEntry(
              childId,
              buckets.map((bucket, values) => MapEntry(bucket, values.toList())),
            )),
        'unlocks': unlocks,
        'minutesByDay': minutesByDay,
        'badges': badges.map((key, value) => MapEntry(key, value.toList())),
        'celebratedGoals': celebratedGoals.toList(),
        'timeWarnDay': timeWarnDay,
        'reminderDay': reminderDay,
      };

  void _apply(Map<String, dynamic>? json) {
    if (json == null) {
      children = [];
      activities = [];
      goals = [];
      notes = [];
      learned = {};
      unlocks = {};
      minutesByDay = {};
      badges = {};
      celebratedGoals = {};
      return;
    }
    parentName = json['parentName'] as String? ?? '';
    parentEmoji = json['parentEmoji'] as String? ?? '🛡️';
    parentEmail = json['parentEmail'] as String? ?? '';
    pin = json['pin'] as String? ?? '';
    pinIsSet = json['pinIsSet'] as bool? ?? false;
    pinEnabled = json['pinEnabled'] as bool? ?? true;
    soundEnabled = json['soundEnabled'] as bool? ?? true;
    language = json['language'] as String? ?? 'English';
    dailyMinutes = (json['dailyMinutes'] as num?)?.toInt() ?? 30;
    breakReminders = json['breakReminders'] as bool? ?? true;
    sessionLimit = json['sessionLimit'] as bool? ?? true;
    bedtimeRestriction = json['bedtimeRestriction'] as bool? ?? false;
    bedtimeHour = (json['bedtimeHour'] as num?)?.toInt() ?? 20;
    dailyReminder = json['dailyReminder'] as bool? ?? true;
    enabledDays = {...((json['enabledDays'] as List?)?.map((day) => day.toString()) ?? weekDayLabels)};
    if (enabledDays.isEmpty) enabledDays = {...weekDayLabels};
    achievementNotifs = json['achievementNotifs'] as bool? ?? true;
    progressReports = json['progressReports'] as bool? ?? true;
    aiRecommendations = json['aiRecommendations'] as bool? ?? true;
    children = [
      for (final item in (json['children'] as List? ?? []))
        if (item is Map) ChildProfile.fromJson(item.map((key, value) => MapEntry(key.toString(), value))),
    ];
    activeChildId = json['activeChildId'] as String? ?? (children.isEmpty ? '' : children.first.id);
    activities = [
      for (final item in (json['activities'] as List? ?? []))
        if (item is Map) ActivityRecord.fromJson(item.map((key, value) => MapEntry(key.toString(), value))),
    ];
    goals = [
      for (final item in (json['goals'] as List? ?? []))
        if (item is Map) LearningGoal.fromJson(item.map((key, value) => MapEntry(key.toString(), value))),
    ];
    notes = [
      for (final item in (json['notes'] as List? ?? []))
        if (item is Map) AppNote.fromJson(item.map((key, value) => MapEntry(key.toString(), value))),
    ];
    learned = _readLearned(json['learned']);
    unlocks = _readIntMap(json['unlocks']);
    minutesByDay = _readIntMap(json['minutesByDay']);
    badges = _readSets(json['badges']);
    celebratedGoals = {...((json['celebratedGoals'] as List?)?.map((item) => item.toString()) ?? <String>[])};
    timeWarnDay = json['timeWarnDay'] as String?;
    reminderDay = json['reminderDay'] as String?;
    updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now();
  }

  Map<String, Map<String, Set<String>>> _readLearned(dynamic raw) {
    final result = <String, Map<String, Set<String>>>{};
    if (raw is! Map) return result;
    raw.forEach((childId, buckets) {
      final parsed = <String, Set<String>>{};
      if (buckets is Map) {
        buckets.forEach((bucket, values) {
          parsed[bucket.toString()] = {if (values is List) ...values.map((value) => value.toString())};
        });
      }
      result[childId.toString()] = parsed;
    });
    return result;
  }

  Map<String, Map<String, int>> _readIntMap(dynamic raw) {
    final result = <String, Map<String, int>>{};
    if (raw is! Map) return result;
    raw.forEach((childId, values) {
      final parsed = <String, int>{};
      if (values is Map) {
        values.forEach((key, value) {
          parsed[key.toString()] = value is num ? value.toInt() : int.tryParse('$value') ?? 0;
        });
      }
      result[childId.toString()] = parsed;
    });
    return result;
  }

  Map<String, Set<String>> _readSets(dynamic raw) {
    final result = <String, Set<String>>{};
    if (raw is! Map) return result;
    raw.forEach((key, values) {
      result[key.toString()] = {if (values is List) ...values.map((value) => value.toString())};
    });
    return result;
  }

  Future<Map<String, dynamic>?> _fetchRemote(String uid) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('guardians').doc(uid).get();
      if (!snap.exists) return null;
      final data = snap.data();
      final notebook = data?['notebook'];
      if (notebook is Map) {
        return notebook.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (error) {
      syncNote = 'Saved on this phone. Cloud sync will start when Firestore is turned on.';
      debugPrint('Notebook sync skipped: $error');
    }
    return null;
  }

  Future<void> _pullRemote() async {
    final uid = _uid;
    if (uid == null) return;
    final remote = await _fetchRemote(uid);
    if (remote == null) {
      await _pushRemote();
      return;
    }
    final remoteAt = DateTime.tryParse(remote['updatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
    if (remoteAt.isAfter(updatedAt)) {
      _apply(remote);
      if (children.isEmpty) _seedChild();
      await _writeLocal();
      notifyListeners();
    }
  }

  Future<void> _pushRemote() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('guardians').doc(uid).set({
        'updatedAt': updatedAt.toIso8601String(),
        'notebook': toJson(),
      });
      syncNote = null;
    } catch (error) {
      syncNote = 'Saved on this phone. Cloud sync will start when Firestore is turned on.';
      debugPrint('Notebook upload skipped: $error');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _syncTimer?.cancel();
    super.dispose();
  }
}

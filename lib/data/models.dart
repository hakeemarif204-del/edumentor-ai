class ChildProfile {
  final String id;
  String name;
  int age;
  String avatarEmoji;
  String level;
  String focusSubject;

  ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.avatarEmoji,
    this.level = 'Beginner',
    this.focusSubject = 'Alphabets',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'avatarEmoji': avatarEmoji,
        'level': level,
        'focusSubject': focusSubject,
      };

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String? ?? 'child',
      name: json['name'] as String? ?? 'Little Learner',
      age: (json['age'] as num?)?.toInt() ?? 4,
      avatarEmoji: json['avatarEmoji'] as String? ?? '🌟',
      level: json['level'] as String? ?? 'Beginner',
      focusSubject: json['focusSubject'] as String? ?? 'Alphabets',
    );
  }
}

class ActivityRecord {
  final String id;
  final String childId;
  final String subject;
  final String title;
  final int score;
  final int stars;
  final DateTime at;

  const ActivityRecord({
    required this.id,
    required this.childId,
    required this.subject,
    required this.title,
    required this.score,
    required this.stars,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'childId': childId,
        'subject': subject,
        'title': title,
        'score': score,
        'stars': stars,
        'at': at.toIso8601String(),
      };

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as String? ?? '',
      childId: json['childId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      title: json['title'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 0,
      at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class LearningGoal {
  final String id;
  final String childId;
  String title;
  String subject;
  String subjectEmoji;
  int target;
  DateTime createdAt;
  DateTime? deadline;

  LearningGoal({
    required this.id,
    required this.childId,
    required this.title,
    required this.subject,
    required this.subjectEmoji,
    required this.target,
    required this.createdAt,
    this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'childId': childId,
        'title': title,
        'subject': subject,
        'subjectEmoji': subjectEmoji,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
      };

  factory LearningGoal.fromJson(Map<String, dynamic> json) {
    return LearningGoal(
      id: json['id'] as String? ?? '',
      childId: json['childId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? 'Alphabets',
      subjectEmoji: json['subjectEmoji'] as String? ?? '🔤',
      target: (json['target'] as num?)?.toInt() ?? 1,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      deadline: json['deadline'] == null ? null : DateTime.tryParse(json['deadline'] as String),
    );
  }
}

class AppNote {
  final String id;
  final String emoji;
  final String title;
  final String body;
  final DateTime at;
  bool isRead;

  AppNote({
    required this.id,
    required this.emoji,
    required this.title,
    required this.body,
    required this.at,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'emoji': emoji,
        'title': title,
        'body': body,
        'at': at.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNote.fromJson(Map<String, dynamic> json) {
    return AppNote(
      id: json['id'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🔔',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class ChildStats {
  final int lettersLearned;
  final int numbersLearned;
  final int shapesLearned;
  final int coloursLearned;
  final int gamesPlayed;
  final int storiesCompleted;
  final int rhymesHeard;
  final int matchingPlayed;
  final int activitiesCompleted;
  final int stars;
  final int streak;
  final double overall;
  final List<double> weekly;
  final Map<String, double> subjectScores;
  final String strongestSubject;
  final String weakestSubject;

  const ChildStats({
    required this.lettersLearned,
    required this.numbersLearned,
    required this.shapesLearned,
    required this.coloursLearned,
    required this.gamesPlayed,
    required this.storiesCompleted,
    required this.rhymesHeard,
    required this.matchingPlayed,
    required this.activitiesCompleted,
    required this.stars,
    required this.streak,
    required this.overall,
    required this.weekly,
    required this.subjectScores,
    required this.strongestSubject,
    required this.weakestSubject,
  });

  static const empty = ChildStats(
    lettersLearned: 0,
    numbersLearned: 0,
    shapesLearned: 0,
    coloursLearned: 0,
    gamesPlayed: 0,
    storiesCompleted: 0,
    rhymesHeard: 0,
    matchingPlayed: 0,
    activitiesCompleted: 0,
    stars: 0,
    streak: 0,
    overall: 0,
    weekly: [0, 0, 0, 0, 0, 0, 0],
    subjectScores: {},
    strongestSubject: 'Alphabets',
    weakestSubject: 'Shapes',
  );
}

class BadgeView {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;

  const BadgeView({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}

const Map<String, String> subjectEmojis = {
  'Alphabets': '🔤',
  'Numbers': '🔢',
  'Colours': '🎨',
  'Shapes': '🔺',
  'Rhymes': '🎵',
  'Stories': '📖',
  'Games': '🎮',
  'Matching': '🧩',
  'Colouring': '🖍️',
  'Science': '🧪',
};

const List<String> weekDayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String weekdayLabel(DateTime date) => weekDayLabels[date.weekday - 1];

String dayKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

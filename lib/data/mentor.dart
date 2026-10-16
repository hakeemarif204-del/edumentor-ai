import 'app_store.dart';

/// A warm kindergarten teacher. Lessons stay inside counting, letters, colours, and shapes.
class Mentor {
  static const _letters = <(String, String, String)>[
    ('A', 'Apple', 'ah'),
    ('B', 'Ball', 'buh'),
    ('C', 'Cat', 'kuh'),
    ('D', 'Dog', 'duh'),
    ('E', 'Egg', 'eh'),
    ('F', 'Fish', 'fff'),
    ('G', 'Goat', 'guh'),
    ('H', 'Hat', 'huh'),
    ('I', 'Igloo', 'ih'),
    ('J', 'Jam', 'juh'),
    ('K', 'Kite', 'kuh'),
    ('L', 'Lion', 'lll'),
    ('M', 'Moon', 'mmm'),
    ('N', 'Nest', 'nnn'),
    ('O', 'Orange', 'oh'),
    ('P', 'Pig', 'puh'),
    ('Q', 'Queen', 'kwuh'),
    ('R', 'Rain', 'rrr'),
    ('S', 'Sun', 'sss'),
    ('T', 'Tiger', 'tuh'),
    ('U', 'Umbrella', 'uh'),
    ('V', 'Van', 'vvv'),
    ('W', 'Water', 'wuh'),
    ('X', 'Box', 'ks'),
    ('Y', 'Yo-yo', 'yuh'),
    ('Z', 'Zebra', 'zzz'),
  ];

  static const _numberWords = [
    'zero',
    'one',
    'two',
    'three',
    'four',
    'five',
    'six',
    'seven',
    'eight',
    'nine',
    'ten',
  ];

  static const _colours = {
    'red': 'Red is like a ripe apple. Can you find something red?',
    'blue': 'Blue is like the sky. Can you point to something blue?',
    'yellow': 'Yellow is like the sun. The sun is yellow and warm.',
    'green': 'Green is like grass. Leaves are green too.',
    'orange': 'Orange is like a juicy orange fruit.',
    'purple': 'Purple is like a bunch of grapes.',
    'pink': 'Pink is like a flower petal.',
    'black': 'Black is like the night sky before the stars come out.',
    'white': 'White is like a fluffy cloud.',
    'brown': 'Brown is like a teddy bear.',
  };

  static const _shapes = {
    'circle': 'A circle is round, like a ball. It has no corners.',
    'square': 'A square has four equal sides, like a window.',
    'triangle': 'A triangle has three sides, like a tent.',
    'rectangle': 'A rectangle has four sides, like a door. Two sides are longer.',
    'star': 'A star has pointy arms, like the star in the night sky.',
    'heart': 'A heart is the shape we draw for love.',
    'oval': 'An oval is a stretched circle, like an egg.',
    'diamond': 'A diamond looks like a kite in the sky.',
  };

  /// Child voice: a short lesson the child can say back.
  static String teach(String question) {
    final name = AppStore.instance.activeChild.name;
    final lesson = _lesson(question.toLowerCase());
    if (lesson != null) return 'Hi $name! $lesson';
    if (_wantsCheer(question.toLowerCase())) return _cheer(name);
    return 'Hi $name! I am your learning friend. '
        'We can say a letter, count to five, or find a colour. '
        'Try asking, what is two plus one?';
  }

  /// Parent voice: kind, and it still offers a kindergarten activity to try together.
  static String answer(String question) {
    final q = question.toLowerCase();
    final lesson = _lesson(q);
    if (lesson != null && !_wantsCheer(q)) {
      final name = AppStore.instance.activeChild.name;
      return 'Here is a little lesson for $name. $lesson';
    }
    return '${summary()} ${_togetherTip()}';
  }

  static String summary() {
    final store = AppStore.instance;
    final child = store.activeChild;
    final stats = store.statsFor(child.id);
    if (stats.activitiesCompleted == 0) {
      return '${child.name} is ready to start. A letter card or counting to five is a happy first lesson.';
    }
    return '${child.name} has finished ${stats.activitiesCompleted} activities and earned ${stats.stars} stars. '
        '${stats.strongestSubject} is going well. ${stats.weakestSubject} would love a little more play. '
        'The learning streak is ${stats.streak} day${stats.streak == 1 ? '' : 's'}.';
  }

  static List<String> strengths() {
    final stats = AppStore.instance.statsFor(AppStore.instance.activeChild.id);
    final found = <String>[];
    if (stats.lettersLearned >= 8) found.add('Saying letters out loud');
    if (stats.numbersLearned >= 5 || (stats.subjectScores['Numbers'] ?? 0) >= 0.7) {
      found.add('Counting');
    }
    if (stats.coloursLearned >= 4) found.add('Naming colours');
    if (stats.shapesLearned >= 4) found.add('Spotting shapes');
    if ((stats.subjectScores['Rhymes'] ?? 0) > 0 || stats.rhymesHeard >= 3) found.add('Rhymes and clapping');
    if (stats.storiesCompleted >= 1) found.add('Listening to stories');
    if (found.isEmpty) return ['Still exploring. A few short lessons will show what they enjoy.'];
    return found;
  }

  static List<String> needsPractice() {
    final stats = AppStore.instance.statsFor(AppStore.instance.activeChild.id);
    final found = <String>[];
    if (stats.lettersLearned < 26) found.add('Letters still to meet (${26 - stats.lettersLearned} left)');
    if (stats.numbersLearned < 10) found.add('Counting through 10');
    if (stats.shapesLearned < 5) found.add('Shapes in the room');
    if (stats.coloursLearned < 6) found.add('Colours nearby');
    if (stats.rhymesHeard < 3) found.add('A rhyme with clapping');
    if (found.isEmpty) return ['Keep the streak with one short game.'];
    return found.take(3).toList();
  }

  static List<String> recommendations() {
    final child = AppStore.instance.activeChild;
    final stats = AppStore.instance.statsFor(child.id);
    return [
      'Sit with ${child.name} for ten gentle minutes on ${stats.weakestSubject.toLowerCase()}.',
      'Focus you chose: ${child.focusSubject}.',
      stats.streak == 0
          ? 'One letter or a count to five starts today\'s streak.'
          : 'The streak is ${stats.streak} day${stats.streak == 1 ? '' : 's'}. One more little activity keeps it.',
    ];
  }

  static bool _wantsCheer(String q) {
    return q.contains('how') || q.contains('progress') || q.contains('doing') || q.contains('next') || q.contains('learn');
  }

  static String _cheer(String name) {
    final stats = AppStore.instance.statsFor(AppStore.instance.activeChild.id);
    final next = _letters[stats.lettersLearned.clamp(0, 25)];
    if (stats.activitiesCompleted == 0) {
      return 'You are in the right place, $name. Let us start small. ${_letterLine(next)}';
    }
    return 'You are doing a wonderful job, $name. '
        'You have met ${stats.lettersLearned} letters and ${stats.numbersLearned} numbers. '
        'I am proud of you. ${_letterLine(next)}';
  }

  static String _togetherTip() {
    final child = AppStore.instance.activeChild;
    final stats = AppStore.instance.statsFor(child.id);
    if (stats.numbersLearned < 5) {
      return 'Try this together: count five fingers, one by one.';
    }
    if (stats.lettersLearned < 8) {
      final next = _letters[stats.lettersLearned.clamp(0, 25)];
      return 'Try this together: ${_letterLine(next)}';
    }
    return 'Try this together: look around and name one colour and one shape.';
  }

  static String? _lesson(String q) {
    final plus = RegExp(r'(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten)\s*(\+|plus|and|add)\s*(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten)');
    final minus = RegExp(r'(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten)\s*(-|minus|take away|subtract)\s*(\d+|zero|one|two|three|four|five|six|seven|eight|nine|ten)');
    final plusMatch = plus.firstMatch(q);
    if (plusMatch != null) {
      return _add(_number(plusMatch.group(1)!), _number(plusMatch.group(3)!));
    }
    final minusMatch = minus.firstMatch(q);
    if (minusMatch != null) {
      return _take(_number(minusMatch.group(1)!), _number(minusMatch.group(3)!));
    }

    final count = RegExp(r'count(?:ing)?(?: to)? (\d+|one|two|three|four|five|six|seven|eight|nine|ten)');
    final countMatch = count.firstMatch(q);
    if (countMatch != null) return _countTo(_number(countMatch.group(1)!));

    if (q.contains('count') || q.contains('number')) {
      final named = _findNumber(q);
      if (named != null) return _countTo(named);
      return _countTo(5);
    }

    for (final entry in _colours.entries) {
      if (q.contains(entry.key)) return entry.value;
    }
    if (q.contains('colour') || q.contains('color')) {
      return 'Let us name colours. ${_colours['yellow']}';
    }

    for (final entry in _shapes.entries) {
      if (q.contains(entry.key)) return entry.value;
    }
    if (q.contains('shape')) return 'Let us find a shape. ${_shapes['circle']}';

    if (q.contains('rhyme') || q.contains('song')) {
      return 'Here is a little rhyme. One little star, two little shoes. Three little claps, just for you. Clap on star, shoes, and you.';
    }
    if (q.contains('story')) {
      return 'Stories have a beginning, a middle, and an end. After a story, ask what happened last.';
    }

    final letter = _findLetter(q);
    if (letter != null) return _letterLine(letter);
    if (q.contains('letter') || q.contains('alphabet') || q.contains('abc')) {
      final known = AppStore.instance.statsFor(AppStore.instance.activeChild.id).lettersLearned;
      return _letterLine(_letters[known.clamp(0, 25)]);
    }

    if (q.contains('time') || q.contains('screen')) {
      final store = AppStore.instance;
      return 'You have used ${store.todayMinutes} learning minutes today. A short lesson is just right.';
    }
    return null;
  }

  static String _letterLine((String, String, String) letter) {
    return '${letter.$1} says ${letter.$3}. ${letter.$1} is for ${letter.$2}. Can you say ${letter.$2}?';
  }

  static (String, String, String)? _findLetter(String q) {
    final named = RegExp(r'letter\s+([a-z])').firstMatch(q);
    if (named != null) return _letters[named.group(1)!.codeUnitAt(0) - 97];
    if (q.trim().length == 1 && q.trim().codeUnitAt(0) >= 97 && q.trim().codeUnitAt(0) <= 122) {
      return _letters[q.trim().codeUnitAt(0) - 97];
    }
    return null;
  }

  static int? _findNumber(String q) {
    final digit = RegExp(r'\b(\d+)\b').firstMatch(q);
    if (digit != null) return int.tryParse(digit.group(1)!);
    for (var i = _numberWords.length - 1; i >= 0; i--) {
      if (q.contains(_numberWords[i])) return i;
    }
    return null;
  }

  static int _number(String raw) {
    final asInt = int.tryParse(raw);
    if (asInt != null) return asInt;
    return _numberWords.indexOf(raw).clamp(0, 10);
  }

  static String _countTo(int n) {
    final safe = n.clamp(1, 10);
    final words = [for (var i = 1; i <= safe; i++) _numberWords[i]];
    return 'Let us count to $safe. ${words.join(', ')}. $safe is ${_numberWords[safe]}. Hold up $safe finger${safe == 1 ? '' : 's'}.';
  }

  static String _add(int a, int b) {
    if (a < 0 || b < 0 || a > 10 || b > 10) {
      return 'Those numbers are big for kindergarten. Let us try two plus one. Two apples and one more apple make three apples.';
    }
    final sum = a + b;
    final total = sum <= 10 ? _numberWords[sum] : '$sum';
    return '$a plus $b. Count ${_numberWords[a]} apple${a == 1 ? '' : 's'}, then ${_numberWords[b]} more. Altogether that is $total.';
  }

  static String _take(int a, int b) {
    if (a > 10 || b > 10 || b > a) {
      return 'Let us take away a little number. Three apples, take away one apple, leaves two apples.';
    }
    final left = a - b;
    return '$a take away $b. Start with ${_numberWords[a]} apples and eat ${_numberWords[b]}. ${_numberWords[left]} ${left == 1 ? 'apple is' : 'apples are'} left.';
  }
}

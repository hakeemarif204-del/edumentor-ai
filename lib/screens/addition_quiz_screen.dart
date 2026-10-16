import 'dart:math';
import 'package:flutter/material.dart';

import '../data/app_store.dart';
import 'addition_progress.dart';

class AdditionQuizScreen extends StatefulWidget {
  final int level;
  const AdditionQuizScreen({super.key, required this.level});

  @override
  State<AdditionQuizScreen> createState() => _AdditionQuizScreenState();
}

class _LevelRange {
  final int min;
  final int max;
  final bool threeNumbers;
  const _LevelRange({required this.min, required this.max, this.threeNumbers = false});
}

class _Question {
  final String expression;
  final int answer;
  final int left;
  final int right;
  late List<int> options;
  _Question({required this.expression, required this.answer, required this.left, required this.right});
}

class _AdditionQuizScreenState extends State<AdditionQuizScreen> {
  final Random _random = Random();

  static const Map<int, _LevelRange> _ranges = {
    1: _LevelRange(min: 1, max: 5),
    2: _LevelRange(min: 10, max: 20),
    3: _LevelRange(min: 20, max: 50),
    4: _LevelRange(min: 50, max: 100),
    5: _LevelRange(min: 100, max: 300),
    6: _LevelRange(min: 300, max: 500),
    7: _LevelRange(min: 500, max: 1000),
    8: _LevelRange(min: 50, max: 300, threeNumbers: true),
    9: _LevelRange(min: 100, max: 500, threeNumbers: true),
    10: _LevelRange(min: 200, max: 900, threeNumbers: true),
  };

  late int _currentLevel;
  late _LevelRange _range;
  int _trialIndex = 0;
  int _correctCount = 0;
  late _Question _question;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
    _range = _ranges[_currentLevel] ?? _ranges[1]!;
    _generateQuestion();
  }

  int _randInRange(int min, int max) => min + _random.nextInt(max - min + 1);

  void _generateQuestion() {
    _Question q;
    if (!_range.threeNumbers) {
      final int a = _randInRange(_range.min, _range.max);
      final int b = _randInRange(_range.min, _range.max);
      q = _Question(expression: '$a + $b', answer: a + b, left: a, right: b);
    } else {
      final int a = _randInRange(_range.min, _range.max);
      final int b = _randInRange((_range.min * 0.5).round(), (_range.max * 0.6).round());
      final int c = _randInRange((_range.min * 0.2).round().clamp(5, 999), (_range.max * 0.3).round());
      q = _Question(expression: '$a + $b + $c', answer: a + b + c, left: a, right: b);
    }

    final Set<int> optionSet = {q.answer};
    int attempts = 0;
    while (optionSet.length < 3 && attempts < 30) {
      attempts++;
      final int spread = max(2, (q.answer * 0.15).round());
      final int offset = _randInRange(-spread, spread);
      final int candidate = q.answer + offset;
      if (candidate >= 0 && candidate != q.answer) {
        optionSet.add(candidate);
      }
    }
    while (optionSet.length < 3) {
      optionSet.add(q.answer + optionSet.length);
    }
    q.options = optionSet.toList()..shuffle(_random);

    setState(() {
      _question = q;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _onAnswer(int chosen) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = chosen;
      _answered = true;
      if (chosen == _question.answer) _correctCount++;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_trialIndex < 9) {
        setState(() => _trialIndex++);
        _generateQuestion();
      } else {
        _onLevelFinished();
      }
    });
  }

  void _onLevelFinished() {
    final bool passed = _correctCount >= 6;
    int stars = 0;
    String verdict;
    if (_correctCount == 10) {
      stars = 3;
      verdict = 'Excellent!';
    } else if (_correctCount >= 8) {
      stars = 2;
      verdict = 'Great job!';
    } else if (_correctCount >= 6) {
      stars = 1;
      verdict = 'Good!';
    } else {
      stars = 0;
      verdict = 'Try the level again!';
    }

    if (passed && AdditionProgress.unlockedLevel < _currentLevel + 1) {
      AdditionProgress.unlockedLevel = _currentLevel + 1;
    }
    AppStore.instance.recordActivity(
      subject: 'Numbers',
      title: 'Addition level $_currentLevel',
      score: _correctCount * 10,
      stars: stars,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(verdict),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(stars > 0 ? '⭐' * stars : '💪', style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text('You got $_correctCount out of 10 correct.'),
            Text('Score: ${_correctCount * 10} points'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Level Select'),
          ),
          if (!passed)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _trialIndex = 0;
                  _correctCount = 0;
                });
                _generateQuestion();
              },
              child: const Text('Try Again'),
            ),
          if (passed && _currentLevel < 10)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _currentLevel++;
                  _range = _ranges[_currentLevel]!;
                  _trialIndex = 0;
                  _correctCount = 0;
                });
                _generateQuestion();
              },
              child: const Text('Next Level'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  _Pill(icon: Icons.flag, label: 'Level $_currentLevel', color: Colors.green),
                  const SizedBox(width: 8),
                  _Pill(icon: Icons.check_circle, label: '$_correctCount correct', color: Colors.teal),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: _trialIndex / 10,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text('Question ${_trialIndex + 1} of 10', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
                      ),
                      child: Column(
                        children: [
                          if (_question.left <= 5 && _question.right <= 5 && !_question.expression.contains('+ +') && _question.expression.split('+').length == 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${'🍎' * _question.left}  +  ${'🍎' * _question.right}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          Text(
                            '${_question.expression} = ?',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF2EBE7B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_answered)
                      Text(
                        _selectedAnswer == _question.answer ? 'Yes! You counted it.' : 'Almost. The answer is ${_question.answer}. Let us try the next one.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _selectedAnswer == _question.answer ? Colors.green : Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _question.options.map((opt) {
                  Color bg = Colors.green[600]!;
                  if (_answered) {
                    if (opt == _question.answer) {
                      bg = Colors.green;
                    } else if (opt == _selectedAnswer) {
                      bg = Colors.red;
                    } else {
                      bg = Colors.grey[400]!;
                    }
                  }
                  return GestureDetector(
                    onTap: () => _onAnswer(opt),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Center(
                        child: Text('$opt', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Pill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
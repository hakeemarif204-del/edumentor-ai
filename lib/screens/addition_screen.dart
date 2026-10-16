import 'dart:math';
import 'package:flutter/material.dart';

class AdditionScreen extends StatefulWidget {
  const AdditionScreen({super.key});

  @override
  State<AdditionScreen> createState() => _AdditionScreenState();
}

class _AdditionScreenState extends State<AdditionScreen> {
  final Random _random = Random();

  late int _numA;
  late int _numB;
  late List<int> _options;
  int _score = 0;
  int _level = 1;
  String? _feedback; // 'correct' or 'wrong' or null

  @override
  void initState() {
    super.initState();
    _newProblem();
  }

  void _newProblem() {
    final a = _random.nextInt(5) + 1; // 1-5
    final b = _random.nextInt(5) + 1; // 1-5
    final correct = a + b;

    // Build 3 options: correct + 2 distractors, all unique, no negatives
    final Set<int> optionSet = {correct};
    while (optionSet.length < 3) {
      final offset = _random.nextInt(5) - 2; // -2 to +2
      final candidate = correct + offset;
      if (candidate > 0) {
        optionSet.add(candidate);
      }
    }
    final options = optionSet.toList()..shuffle(_random);

    setState(() {
      _numA = a;
      _numB = b;
      _options = options;
      _feedback = null;
    });
  }

  void _onAnswer(int chosen) {
    final correct = _numA + _numB;
    if (chosen == correct) {
      setState(() {
        _feedback = 'correct';
        _score += 10;
        if (_score % 50 == 0) _level++;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _newProblem();
      });
    } else {
      setState(() {
        _feedback = 'wrong';
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _feedback = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF7EA),
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
                  _Pill(icon: Icons.star, label: 'Score: $_score', color: Colors.amber),
                  const SizedBox(width: 8),
                  _Pill(icon: Icons.flag, label: 'Level $_level', color: Colors.green),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
                        ],
                      ),
                      child: Text(
                        '$_numA + $_numB = ?',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_feedback == 'correct')
                      const Text('Great job! 🎉', style: TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
                    if (_feedback == 'wrong')
                      const Text('Try again! 🤔', style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _options.map((opt) {
                  return GestureDetector(
                    onTap: () => _onAnswer(opt),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$opt',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
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
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
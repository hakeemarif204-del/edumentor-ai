import 'dart:math';
import 'package:flutter/material.dart';

class CountingGameScreen extends StatefulWidget {
  const CountingGameScreen({super.key});

  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingGameScreenState extends State<CountingGameScreen> {
  final List<String> _fishEmojis = ['🐟', '🐠', '🐡'];
  final Random _random = Random();

  late String _currentFish;
  late int _targetNumber;
  int _fedCount = 0;
  int _score = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    setState(() {
      _currentFish = _fishEmojis[_random.nextInt(_fishEmojis.length)];
      _targetNumber = _random.nextInt(8) + 2; // 2 to 9
      _fedCount = 0;
    });
  }

  void _feedOnePiece() {
    if (_fedCount >= _targetNumber) return;
    setState(() {
      _fedCount++;
    });
    if (_fedCount == _targetNumber) {
      _onFishFed();
    }
  }

  void _onFishFed() {
    setState(() {
      _score += 10;
      if (_score % 50 == 0) {
        _level++;
      }
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _newRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FD3F4),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back, score, level
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
                  _Pill(icon: Icons.flag, label: 'Level $_level', color: Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Old man + fish scene
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Water
                  Positioned.fill(
                    child: Container(color: const Color(0xFF3B8BD4).withOpacity(0.3)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('👴', style: TextStyle(fontSize: 90)),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text('Feed me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  '$_targetNumber',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red,
                                  ),
                                ),
                                const Text('fish food!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_currentFish, style: const TextStyle(fontSize: 90)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Fed count feedback
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Fed: $_fedCount / $_targetNumber',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            // Food pieces row (tap to feed)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEFD0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD9A066), width: 3),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(10, (index) {
                  final bool used = index < _fedCount;
                  return GestureDetector(
                    onTap: used ? null : _feedOnePiece,
                    child: AnimatedOpacity(
                      opacity: used ? 0.25 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: const Text('🟤', style: TextStyle(fontSize: 32)),
                    ),
                  );
                }),
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
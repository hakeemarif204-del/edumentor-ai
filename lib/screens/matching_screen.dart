import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/speaker.dart';

class _MatchCard {
  final String name;
  final String emoji;
  const _MatchCard(this.name, this.emoji);
}

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  static const List<_MatchCard> _pool = [
    _MatchCard('Apple', '🍎'),
    _MatchCard('Cat', '🐱'),
    _MatchCard('Sun', '☀️'),
    _MatchCard('Fish', '🐟'),
    _MatchCard('Star', '⭐'),
    _MatchCard('Heart', '❤️'),
    _MatchCard('Circle', '⭕'),
    _MatchCard('One', '1️⃣'),
    _MatchCard('Two', '2️⃣'),
    _MatchCard('Three', '3️⃣'),
    _MatchCard('Blue', '🔵'),
    _MatchCard('Tree', '🌳'),
  ];

  final Random _random = Random();
  late _MatchCard _target;
  late List<_MatchCard> _options;
  int _round = 1;
  int _correct = 0;
  static const int _total = 8;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final pool = [..._pool]..shuffle(_random);
    _target = pool.first;
    _options = pool.take(4).toList()..shuffle(_random);
  }

  void _pick(_MatchCard card) {
    final right = card.name == _target.name;
    if (right) _correct++;
    Speaker.say(right ? 'Yes, ${card.name}' : 'That is ${card.name}. We wanted ${_target.name}');
    if (_round >= _total) {
      final score = ((_correct / _total) * 100).round();
      final stars = _correct >= 7 ? 3 : _correct >= 5 ? 2 : _correct >= 3 ? 1 : 0;
      AppStore.instance.recordActivity(subject: 'Matching', title: 'Matching game', score: score, stars: stars);
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Matching finished'),
          content: Text('You found $_correct of $_total.\n${stars > 0 ? '⭐' * stars : 'Try once more!'}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _round = 1;
                  _correct = 0;
                  _deal();
                });
              },
              child: const Text('Play again'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _round++;
      _deal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(title: const Text('Matching')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Round $_round of $_total', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            Text('Tap the ${_target.name}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.deepPurple)),
            const SizedBox(height: 8),
            Text('Score $_correct', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                children: [
                  for (final card in _options)
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _pick(card),
                        child: Center(child: Text(card.emoji, style: const TextStyle(fontSize: 64))),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

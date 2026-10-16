import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../data/app_store.dart';
import 'game_progress.dart';

class FeedFishGameScreen extends StatefulWidget {
  final int level;
  const FeedFishGameScreen({super.key, required this.level});

  @override
  State<FeedFishGameScreen> createState() => _FeedFishGameScreenState();
}

class _LevelConfig {
  final int minTarget;
  final int maxTarget;
  final int fishCount;
  final int extraFood;
  final bool hasTimer;
  final int timerSeconds;
  const _LevelConfig({
    required this.minTarget,
    required this.maxTarget,
    required this.fishCount,
    required this.extraFood,
    required this.hasTimer,
    required this.timerSeconds,
  });
}

class _FishTarget {
  final String emoji;
  final int target;
  int fed;
  _FishTarget({required this.emoji, required this.target, this.fed = 0});
}

class _FoodPiece {
  final int id;
  final String emoji;
  final double left; // fraction of arena width, 0..1
  final double top; // fraction of arena height, 0..1
  _FoodPiece({
    required this.id,
    required this.emoji,
    required this.left,
    required this.top,
  });
}

class _FeedFishGameScreenState extends State<FeedFishGameScreen> {
  final Random _random = Random();
  final List<String> _fishEmojis = ['🐟', '🐠', '🐡'];
  final List<String> _foodEmojis = ['🟠', '🟡', '🟢', '🔵', '🟣', '🔴'];

  static const Map<int, _LevelConfig> _levelConfigs = {
    1: _LevelConfig(minTarget: 1, maxTarget: 5, fishCount: 1, extraFood: 3, hasTimer: false, timerSeconds: 0),
    2: _LevelConfig(minTarget: 3, maxTarget: 7, fishCount: 1, extraFood: 5, hasTimer: false, timerSeconds: 0),
    3: _LevelConfig(minTarget: 5, maxTarget: 10, fishCount: 1, extraFood: 6, hasTimer: false, timerSeconds: 0),
    4: _LevelConfig(minTarget: 5, maxTarget: 10, fishCount: 1, extraFood: 8, hasTimer: false, timerSeconds: 0),
    5: _LevelConfig(minTarget: 5, maxTarget: 10, fishCount: 1, extraFood: 6, hasTimer: true, timerSeconds: 35),
    6: _LevelConfig(minTarget: 3, maxTarget: 8, fishCount: 2, extraFood: 6, hasTimer: false, timerSeconds: 0),
    7: _LevelConfig(minTarget: 3, maxTarget: 8, fishCount: 2, extraFood: 2, hasTimer: true, timerSeconds: 45),
  };

  late int _currentLevel;
  late _LevelConfig _config;
  late List<_FishTarget> _fishList;
  late List<_FoodPiece> _foodPieces;
  int _nextFoodId = 0;
  int _secondsLeft = 0;
  Timer? _timer;
  bool _showMessage = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
    _config = _levelConfigs[_currentLevel] ?? _levelConfigs[1]!;
    _setupRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupRound() {
    _timer?.cancel();

    final List<String> shuffledFish = List.of(_fishEmojis)..shuffle(_random);
    _fishList = List.generate(_config.fishCount, (i) {
      final target = _config.minTarget + _random.nextInt(_config.maxTarget - _config.minTarget + 1);
      return _FishTarget(emoji: shuffledFish[i % shuffledFish.length], target: target);
    });

    final int totalNeeded = _fishList.fold(0, (sum, f) => sum + f.target);
    final int totalFood = totalNeeded + _config.extraFood;

    // Scatter food using a shuffled grid so pieces don't overlap much,
    // but still look randomly placed (not in order).
    const int cols = 4;
    final int rows = (totalFood / cols).ceil() + 1;
    final List<Point<int>> cells = [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        cells.add(Point(c, r));
      }
    }
    cells.shuffle(_random);

    _foodPieces = List.generate(totalFood, (i) {
      final cell = cells[i % cells.length];
      final double cellW = 1 / cols;
      final double cellH = 1 / rows;
      final double jitterX = (_random.nextDouble() - 0.5) * cellW * 0.5;
      final double jitterY = (_random.nextDouble() - 0.5) * cellH * 0.5;
      final double left = ((cell.x + 0.5) * cellW + jitterX).clamp(0.05, 0.88);
      final double top = ((cell.y + 0.5) * cellH + jitterY).clamp(0.05, 0.85);
      return _FoodPiece(
        id: _nextFoodId++,
        emoji: _foodEmojis[_random.nextInt(_foodEmojis.length)],
        left: left,
        top: top,
      );
    });

    if (_config.hasTimer) {
      _secondsLeft = _config.timerSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _secondsLeft--;
        });
        if (_secondsLeft <= 0) {
          t.cancel();
          _onTimeUp();
        }
      });
    }
  }

  void _onTimeUp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Time's up! ⏰"),
        content: const Text("Don't worry, let's try again!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _setupRound();
              });
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _flashMessage(String message) {
    setState(() {
      _message = message;
      _showMessage = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showMessage = false);
    });
  }

  void _feedFish(_FishTarget fish, _FoodPiece food) {
    if (fish.fed >= fish.target) {
      _flashMessage("That's enough! Great counting! 🌟");
      return;
    }
    setState(() {
      fish.fed++;
      _foodPieces.removeWhere((f) => f.id == food.id);
    });

    final bool allFed = _fishList.every((f) => f.fed >= f.target);
    if (allFed) {
      _timer?.cancel();
      Future.delayed(const Duration(milliseconds: 300), _onLevelComplete);
    }
  }

  void _onLevelComplete() {
    if (GameProgress.unlockedLevel < _currentLevel + 1) {
      GameProgress.unlockedLevel = _currentLevel + 1;
    }
    AppStore.instance.recordActivity(
      subject: 'Games',
      title: 'Feed the Fish level $_currentLevel',
      score: 100,
      stars: 3,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Great job!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⭐⭐⭐', style: TextStyle(fontSize: 32)),
            SizedBox(height: 8),
            Text('You fed all the fish perfectly!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to level select
            },
            child: const Text('Level Select'),
          ),
          if (_currentLevel < 7)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                setState(() {
                  _currentLevel++;
                  _config = _levelConfigs[_currentLevel]!;
                  _setupRound();
                });
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
      backgroundColor: const Color(0xFF8FD3F4),
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
                  const SizedBox(width: 10),
                  _Pill(icon: Icons.flag, label: 'Level $_currentLevel', color: Colors.blue),
                  const Spacer(),
                  if (_config.hasTimer)
                    _Pill(
                      icon: Icons.timer,
                      label: '$_secondsLeft s',
                      color: _secondsLeft <= 10 ? Colors.red : Colors.orange,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _fishList
                    .map((fish) => _FishWidget(
                          fish: fish,
                          onFoodDropped: (food) => _feedFish(fish, food),
                        ))
                    .toList(),
              ),
            ),
            if (_showMessage)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_message, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _foodPieces.map((food) {
                      return Positioned(
                        left: food.left * constraints.maxWidth,
                        top: food.top * constraints.maxHeight,
                        child: Draggable<_FoodPiece>(
                          data: food,
                          feedback: Text(food.emoji, style: const TextStyle(fontSize: 56)),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: Text(food.emoji, style: const TextStyle(fontSize: 44)),
                          ),
                          child: Text(food.emoji, style: const TextStyle(fontSize: 44)),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FishWidget extends StatelessWidget {
  final _FishTarget fish;
  final void Function(_FoodPiece food) onFoodDropped;
  const _FishWidget({required this.fish, required this.onFoodDropped});

  @override
  Widget build(BuildContext context) {
    return DragTarget<_FoodPiece>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) => onFoodDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final bool hovering = candidateData.isNotEmpty;
        return AnimatedScale(
          scale: hovering ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Text('Feed me ${fish.target}!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Fed: ${fish.fed}/${fish.target}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(fish.emoji, style: const TextStyle(fontSize: 70)),
            ],
          ),
        );
      },
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
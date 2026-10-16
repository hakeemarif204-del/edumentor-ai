import 'package:flutter/material.dart';
import '../data/session_host.dart';
import '../theme/kid_theme.dart';
import 'feed_fish_game_screen.dart';
import 'game_progress.dart';

class FeedFishLevelSelectScreen extends StatefulWidget {
  const FeedFishLevelSelectScreen({super.key});

  @override
  State<FeedFishLevelSelectScreen> createState() => _FeedFishLevelSelectScreenState();
}

class _FeedFishLevelSelectScreenState extends State<FeedFishLevelSelectScreen> {
  static const _levelNames = [
    'Count a few',
    'Count a little more',
    'Count to 10',
    'Careful counting',
    'A quick count',
    'More fish',
    'Champion fish',
  ];

  Future<void> _openLevel(int level) async {
    await openLearning(context, page: FeedFishGameScreen(level: level));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.cream,
      appBar: AppBar(title: const Text('Feed the fish')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const KidIntro(
              emoji: '🐠',
              title: 'Count, then feed',
              message: 'Look at the number, count that many bites, and feed the fish.',
            ),
            Expanded(
              child: GridView.builder(
                itemCount: _levelNames.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final level = index + 1;
                  final unlocked = level <= GameProgress.unlockedLevel;
                  return KidLevelTile(
                    title: 'Level $level',
                    subtitle: _levelNames[index],
                    emoji: '🐠',
                    unlocked: unlocked,
                    accent: KidColors.sky,
                    onTap: unlocked ? () => _openLevel(level) : null,
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

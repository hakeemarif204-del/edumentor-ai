import 'package:flutter/material.dart';
import '../data/session_host.dart';
import '../theme/kid_theme.dart';
import 'numbers_screen.dart';
import 'feed_fish_level_select_screen.dart';
import 'addition_level_select_screen.dart';
import 'subtraction_level_select_screen.dart';
import 'writing_practice_screen.dart';

class NumbersHubScreen extends StatelessWidget {
  const NumbersHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.cream,
      appBar: AppBar(title: const Text('Numbers')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const KidIntro(
              emoji: '🔢',
              title: 'Little numbers',
              message: 'Start with counting. Then add and take away with your fingers.',
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.86,
                children: [
                  KidTile(
                    title: 'Counting 1–10',
                    subtitle: 'Say each number',
                    emoji: '🔢',
                    accent: KidColors.sun,
                    onTap: () => openLearning(context, page: const NumbersScreen()),
                  ),
                  KidTile(
                    title: 'Add',
                    subtitle: 'Put groups together',
                    emoji: '➕',
                    accent: KidColors.leaf,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdditionLevelSelectScreen())),
                  ),
                  KidTile(
                    title: 'Take away',
                    subtitle: 'See what is left',
                    emoji: '➖',
                    accent: KidColors.sky,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubtractionLevelSelectScreen())),
                  ),
                  KidTile(
                    title: 'Trace',
                    subtitle: 'English and numbers',
                    emoji: '✏️',
                    accent: KidColors.plum,
                    onTap: () => openLearning(context, page: const WritingPracticeScreen()),
                  ),
                  KidTile(
                    title: 'Feed the fish',
                    subtitle: 'Count, then feed',
                    emoji: '🐠',
                    accent: KidColors.coral,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedFishLevelSelectScreen())),
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

import 'package:flutter/material.dart';

import '../data/session_host.dart';
import '../theme/kid_theme.dart';
import 'addition_level_select_screen.dart';
import 'feed_fish_level_select_screen.dart';
import 'matching_screen.dart';
import 'subtraction_level_select_screen.dart';

class GamesHubScreen extends StatelessWidget {
  const GamesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.cream,
      appBar: AppBar(title: const Text('Fun games')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const KidIntro(
              emoji: '🐠',
              title: 'Play a little',
              message: 'Each game uses counting, matching, or taking away.',
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  KidTile(
                    title: 'Feed the fish',
                    subtitle: 'Count the bites',
                    emoji: '🐠',
                    accent: KidColors.sky,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedFishLevelSelectScreen())),
                  ),
                  KidTile(
                    title: 'Matching',
                    subtitle: 'Find the pair',
                    emoji: '🧩',
                    accent: KidColors.sun,
                    onTap: () => openLearning(context, page: const MatchingScreen()),
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
                    accent: KidColors.coral,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubtractionLevelSelectScreen())),
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

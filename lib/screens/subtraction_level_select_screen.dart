import 'package:flutter/material.dart';
import '../data/session_host.dart';
import '../theme/kid_theme.dart';
import 'subtraction_quiz_screen.dart';
import 'subtraction_progress.dart';

class SubtractionLevelSelectScreen extends StatefulWidget {
  const SubtractionLevelSelectScreen({super.key});

  @override
  State<SubtractionLevelSelectScreen> createState() => _SubtractionLevelSelectScreenState();
}

class _SubtractionLevelSelectScreenState extends State<SubtractionLevelSelectScreen> {
  static const _levelNames = [
    'Take away, 1 to 5',
    'Up to 10',
    'Teen numbers',
    'Up to 50',
    'Up to 100',
    'Bigger numbers',
    'Hundreds',
    'Three numbers',
    'More steps',
    'Champion',
  ];

  Future<void> _openLevel(int level) async {
    await openLearning(context, page: SubtractionQuizScreen(level: level));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.cream,
      appBar: AppBar(title: const Text('Take away')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const KidIntro(
              emoji: '➖',
              title: 'See what is left',
              message: 'Start small. Take some apples away and count the ones still there.',
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
                  final unlocked = level <= SubtractionProgress.unlockedLevel;
                  return KidLevelTile(
                    title: 'Level $level',
                    subtitle: _levelNames[index],
                    emoji: level == 10 ? '🏆' : '➖',
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

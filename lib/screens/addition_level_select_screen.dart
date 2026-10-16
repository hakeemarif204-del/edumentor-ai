import 'package:flutter/material.dart';
import '../data/session_host.dart';
import '../theme/kid_theme.dart';
import 'addition_quiz_screen.dart';
import 'addition_progress.dart';

class AdditionLevelSelectScreen extends StatefulWidget {
  const AdditionLevelSelectScreen({super.key});

  @override
  State<AdditionLevelSelectScreen> createState() => _AdditionLevelSelectScreenState();
}

class _AdditionLevelSelectScreenState extends State<AdditionLevelSelectScreen> {
  static const _levelNames = [
    'Fingers, 1 to 5',
    'Up to 10',
    'Teen numbers',
    'Up to 50',
    'Up to 100',
    'Bigger sums',
    'Hundreds',
    'Three numbers',
    'More steps',
    'Champion',
  ];

  Future<void> _openLevel(int level) async {
    await openLearning(context, page: AdditionQuizScreen(level: level));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.cream,
      appBar: AppBar(title: const Text('Add')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const KidIntro(
              emoji: '➕',
              title: 'Put groups together',
              message: 'Start with Fingers. Count the apples, then say the total.',
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
                  final unlocked = level <= AdditionProgress.unlockedLevel;
                  return KidLevelTile(
                    title: 'Level $level',
                    subtitle: _levelNames[index],
                    emoji: level == 10 ? '🏆' : '➕',
                    unlocked: unlocked,
                    accent: KidColors.leaf,
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

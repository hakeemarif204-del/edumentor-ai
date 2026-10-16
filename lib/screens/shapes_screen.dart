import 'package:flutter/material.dart';
import 'learn_quiz_screen.dart';

class ShapesScreen extends StatelessWidget {
  const ShapesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearnQuizScreen(
      subject: 'Shapes',
      title: 'Shapes',
      learnedBucket: 'shapes',
      accent: Color(0xFF1565C0),
      items: [
        LessonItem(id: 'circle', name: 'Circle', emoji: '⭕', speech: 'This is a circle. A circle is round.'),
        LessonItem(id: 'square', name: 'Square', emoji: '⬜', speech: 'This is a square. A square has four equal sides.'),
        LessonItem(id: 'triangle', name: 'Triangle', emoji: '🔺', speech: 'This is a triangle. A triangle has three sides.'),
        LessonItem(id: 'star', name: 'Star', emoji: '⭐', speech: 'This is a star. A star has points.'),
        LessonItem(id: 'heart', name: 'Heart', emoji: '❤️', speech: 'This is a heart.'),
        LessonItem(id: 'diamond', name: 'Diamond', emoji: '💎', speech: 'This is a diamond. It looks like a kite.'),
        LessonItem(id: 'rectangle', name: 'Rectangle', emoji: '🟦', speech: 'This is a rectangle. It is a long box shape.'),
        LessonItem(id: 'oval', name: 'Oval', emoji: '🥚', speech: 'This is an oval. An oval is like a stretched circle.'),
      ],
    );
  }
}

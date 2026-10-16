import 'package:flutter/material.dart';
import 'learn_quiz_screen.dart';

class ColoursScreen extends StatelessWidget {
  const ColoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearnQuizScreen(
      subject: 'Colours',
      title: 'Colours',
      learnedBucket: 'colours',
      accent: Color(0xFFC2185B),
      items: [
        LessonItem(id: 'red', name: 'Red', emoji: '🔴', speech: 'This is red.'),
        LessonItem(id: 'orange', name: 'Orange', emoji: '🟠', speech: 'This is orange.'),
        LessonItem(id: 'yellow', name: 'Yellow', emoji: '🟡', speech: 'This is yellow.'),
        LessonItem(id: 'green', name: 'Green', emoji: '🟢', speech: 'This is green.'),
        LessonItem(id: 'blue', name: 'Blue', emoji: '🔵', speech: 'This is blue.'),
        LessonItem(id: 'purple', name: 'Purple', emoji: '🟣', speech: 'This is purple.'),
        LessonItem(id: 'pink', name: 'Pink', emoji: '💗', speech: 'This is pink.'),
        LessonItem(id: 'brown', name: 'Brown', emoji: '🟤', speech: 'This is brown.'),
      ],
    );
  }
}

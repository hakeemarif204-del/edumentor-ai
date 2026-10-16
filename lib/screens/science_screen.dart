import 'package:flutter/material.dart';
import 'learn_quiz_screen.dart';

class ScienceScreen extends StatelessWidget {
  const ScienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearnQuizScreen(
      subject: 'Science',
      title: 'Science Fun',
      learnedBucket: 'science',
      accent: Color(0xFF00796B),
      items: [
        LessonItem(id: 'sun', name: 'Sun', emoji: '☀️', speech: 'The sun is a star. It gives us light.', fact: 'The sun is a star that lights the day.'),
        LessonItem(id: 'fish', name: 'Fish', emoji: '🐟', speech: 'Fish live in water.', fact: 'Fish breathe in water.'),
        LessonItem(id: 'plant', name: 'Plant', emoji: '🌱', speech: 'Plants need water and light.', fact: 'A plant drinks water and likes sunshine.'),
        LessonItem(id: 'cloud', name: 'Cloud', emoji: '☁️', speech: 'Rain comes from clouds.', fact: 'Clouds can make rain.'),
        LessonItem(id: 'heart', name: 'Heart', emoji: '💓', speech: 'Your heart pumps blood through your body.', fact: 'Your heart keeps blood moving.'),
        LessonItem(id: 'ice', name: 'Ice', emoji: '🧊', speech: 'Ice is frozen water.', fact: 'Ice is water that got very cold.'),
        LessonItem(id: 'bee', name: 'Bee', emoji: '🐝', speech: 'Bees help flowers grow.', fact: 'Bees carry pollen from flower to flower.'),
        LessonItem(id: 'moon', name: 'Moon', emoji: '🌙', speech: 'The moon shines at night because it reflects the sun.', fact: 'The moon glows with sunlight.'),
      ],
    );
  }
}

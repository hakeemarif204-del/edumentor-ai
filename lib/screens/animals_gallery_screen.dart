import 'package:flutter/material.dart';

class AnimalsGalleryScreen extends StatelessWidget {
  const AnimalsGalleryScreen({super.key});

  static const List<_AnimalCardData> _animals = [
    _AnimalCardData('Lion', '🦁', Color(0xFFFFF3E0), Color(0xFFFF9800)),
    _AnimalCardData('Panda', '🐼', Color(0xFFE3F2FD), Color(0xFF2196F3)),
    _AnimalCardData('Elephant', '🐘', Color(0xFFE8F5E9), Color(0xFF4CAF50)),
    _AnimalCardData('Giraffe', '🦒', Color(0xFFF3E5F5), Color(0xFF6B4EFF)),
    _AnimalCardData('Tiger', '🐯', Color(0xFFFFEBEE), Color(0xFFE91E63)),
    _AnimalCardData('Turtle', '🐢', Color(0xFFE0F7FA), Color(0xFF00BCD4)),
    _AnimalCardData('Dolphin', '🐬', Color(0xFFEDE7F6), Color(0xFF673AB7)),
    _AnimalCardData('Koala', '🐨', Color(0xFFE0F2F1), Color(0xFF009688)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3B2A5A)),
        title: const Text(
          'Animals Gallery',
          style: TextStyle(
            color: Color(0xFF3B2A5A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            itemCount: _animals.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final animal = _animals[index];
              return Container(
                decoration: BoxDecoration(
                  color: animal.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${animal.name} is ready to colour!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          animal.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          animal.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: animal.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimalCardData {
  final String name;
  final String emoji;
  final Color background;
  final Color accent;

  const _AnimalCardData(this.name, this.emoji, this.background, this.accent);
}

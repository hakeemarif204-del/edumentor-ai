import 'package:flutter/material.dart';

import '../data/session_host.dart';
import 'colouring_canvas_screen.dart';

class PictureSetScreen extends StatelessWidget {
  final String title;
  final List<PicturePage> pictures;

  const PictureSetScreen({super.key, required this.title, required this.pictures});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(title: Text(title)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pictures.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
        ),
        itemBuilder: (context, index) {
          final picture = pictures[index];
          return Material(
            color: picture.background,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => openLearning(
                context,
                page: ColouringCanvasScreen(title: picture.name, templateEmoji: picture.emoji),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(picture.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 8),
                  Text(picture.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PicturePage {
  final String name;
  final String emoji;
  final Color background;
  const PicturePage(this.name, this.emoji, this.background);
}

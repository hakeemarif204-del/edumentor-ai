import 'package:flutter/material.dart';
import '../data/session_host.dart';
import '../theme/kid_theme.dart';
import 'colouring_canvas_screen.dart';
import 'picture_set_screen.dart';

class _ColouringTile {
  final String title;
  final String emoji;
  final Color accent;

  const _ColouringTile({
    required this.title,
    required this.emoji,
    required this.accent,
  });
}

class ColouringHubScreen extends StatelessWidget {
  const ColouringHubScreen({super.key});

  static const List<_ColouringTile> _tiles = [
    _ColouringTile(title: 'Adventures', emoji: '🚀', accent: KidColors.plum),
    _ColouringTile(title: 'Animals', emoji: '🐾', accent: KidColors.sun),
    _ColouringTile(title: 'My Drawing', emoji: '✏️', accent: KidColors.leaf),
    _ColouringTile(title: 'Art Studio', emoji: '🎨', accent: KidColors.sky),
  ];

  void _openTile(BuildContext context, _ColouringTile tile) {
    switch (tile.title) {
      case 'My Drawing':
        openLearning(context, page: const ColouringCanvasScreen());
        break;
      case 'Animals':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PictureSetScreen(
              title: 'Animals',
              pictures: [
                PicturePage('Lion', '🦁', Color(0xFFFFF3E0)),
                PicturePage('Panda', '🐼', Color(0xFFE3F2FD)),
                PicturePage('Elephant', '🐘', Color(0xFFE8F5E9)),
                PicturePage('Giraffe', '🦒', Color(0xFFF3E5F5)),
                PicturePage('Tiger', '🐯', Color(0xFFFFEBEE)),
                PicturePage('Turtle', '🐢', Color(0xFFE0F7FA)),
              ],
            ),
          ),
        );
        break;
      case 'Adventures':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PictureSetScreen(
              title: 'Adventures',
              pictures: [
                PicturePage('Rocket', '🚀', Color(0xFFEDE7F6)),
                PicturePage('Castle', '🏰', Color(0xFFF3E5F5)),
                PicturePage('Boat', '⛵', Color(0xFFE3F2FD)),
                PicturePage('Dinosaur', '🦕', Color(0xFFE8F5E9)),
                PicturePage('Treasure', '💎', Color(0xFFFFF8E1)),
                PicturePage('Rainbow', '🌈', Color(0xFFFCE4EC)),
              ],
            ),
          ),
        );
        break;
      case 'Art Studio':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PictureSetScreen(
              title: 'Art Studio',
              pictures: [
                PicturePage('Palette', '🎨', Color(0xFFF3E5F5)),
                PicturePage('Brush', '🖌️', Color(0xFFE3F2FD)),
                PicturePage('Crayons', '🖍️', Color(0xFFFFF3E0)),
                PicturePage('Frame', '🖼️', Color(0xFFE8F5E9)),
                PicturePage('Stars', '✨', Color(0xFFFFF8E1)),
                PicturePage('Flower', '🌸', Color(0xFFFCE4EC)),
              ],
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.cream,
      appBar: AppBar(title: const Text('Colouring')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const KidIntro(
              emoji: '🎨',
              title: 'Colour a picture',
              message: 'Pick animals, adventures, or start your own drawing.',
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  for (final tile in _tiles)
                    KidTile(
                      title: tile.title,
                      subtitle: tile.title == 'My Drawing' ? 'A blank page' : 'Ready to colour',
                      emoji: tile.emoji,
                      accent: tile.accent,
                      onTap: () => _openTile(context, tile),
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
import 'package:flutter/material.dart';

import '../data/app_store.dart';

class _Stroke {
  final List<Offset> points;
  final Color color;
  final double width;

  _Stroke({required this.points, required this.color, required this.width});
}

class ColouringCanvasScreen extends StatefulWidget {
  final String title;
  final String? templateEmoji;

  const ColouringCanvasScreen({super.key, this.title = 'My Drawing', this.templateEmoji});

  @override
  State<ColouringCanvasScreen> createState() => _ColouringCanvasScreenState();
}

class _ColouringCanvasScreenState extends State<ColouringCanvasScreen> {
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;
  bool _saved = false;

  Color _selectedColor = const Color(0xFFE91E63);
  double _brushWidth = 10;

  final List<Color> _palette = const [
    Color(0xFF6B4EFF),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF673AB7),
    Colors.black,
    Colors.brown,
  ];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = _Stroke(
        points: [details.localPosition],
        color: _selectedColor,
        width: _brushWidth,
      );
      _strokes.add(_currentStroke!);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke?.points.add(details.localPosition);
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _clearAll() {
    setState(() => _strokes.clear());
  }

  @override
  void dispose() {
    if (!_saved && _strokes.isNotEmpty) {
      _saved = true;
      AppStore.instance.recordActivity(
        subject: 'Colouring',
        title: widget.title,
        score: 100,
        stars: 2,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clearAll),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.templateEmoji != null)
                      Center(
                        child: Text(widget.templateEmoji!, style: TextStyle(fontSize: 160, color: Colors.black.withValues(alpha: 0.18))),
                      ),
                    CustomPaint(
                      painter: _CanvasPainter(_strokes),
                      size: Size.infinite,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Slider(
              value: _brushWidth,
              min: 4,
              max: 30,
              activeColor: _selectedColor,
              onChanged: (v) => setState(() => _brushWidth = v),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _palette.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final color = _palette[index];
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  _CanvasPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}
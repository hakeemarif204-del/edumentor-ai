import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_store.dart';
import '../data/speaker.dart';
import '../data/trace_glyphs.dart';

class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({super.key});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _Ink {
  final Offset point;
  final Color color;
  const _Ink(this.point, this.color);
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  int _mode = 0;
  int _index = 0;
  Color _crayon = const Color(0xFF8BC34A);
  final List<_Ink> _ink = [];
  bool _drew = false;
  bool _done = false;
  bool _saved = false;
  int _finished = 0;
  Size _board = Size.zero;

  static const _crayons = [
    Color(0xFFE0A100),
    Color(0xFF3D7DFF),
    Color(0xFF8BC34A),
  ];

  List<TraceGlyph> get _set => _mode == 0 ? englishGlyphs : numberGlyphs;
  TraceGlyph get _glyph => _set[_index];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _speak();
  }

  @override
  void dispose() {
    if (!_saved && (_drew || _finished > 0)) {
      _saved = true;
      AppStore.instance.recordActivity(
        subject: _mode == 0 ? 'Alphabets' : 'Numbers',
        title: _mode == 0 ? 'Trace letters' : 'Trace numbers',
        score: _finished > 0 ? 100 : 40,
        stars: _finished >= 3 ? 3 : _finished > 0 ? 2 : 1,
      );
    }
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _speak() {
    Speaker.say(_glyph.spoken);
  }

  void _switchMode(int mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _index = 0;
      _clear();
    });
    _speak();
  }

  void _clear() {
    _ink.clear();
    _drew = false;
    _done = false;
  }

  void _go(int step) {
    setState(() {
      _index = (_index + step + _set.length) % _set.length;
      _clear();
    });
    _speak();
  }

  Offset _map(Offset unit) {
    const pad = 0.12;
    return Offset(
      _board.width * (pad + unit.dx * (1 - pad * 2)),
      _board.height * (pad + unit.dy * (1 - pad * 2)),
    );
  }

  void _onStart(DragStartDetails details) {
    if (_done) return;
    setState(() {
      _drew = true;
      _ink.add(_Ink(details.localPosition, _crayon));
    });
  }

  void _onMove(DragUpdateDetails details) {
    if (_done) return;
    setState(() {
      _drew = true;
      _ink.add(_Ink(details.localPosition, _crayon));
    });
    _check();
  }

  void _check() {
    if (_board == Size.zero || _ink.length < 8 || _done) return;
    final samples = <Offset>[];
    for (final stroke in _glyph.strokes) {
      for (var i = 0; i < stroke.length - 1; i++) {
        final a = _map(stroke[i]);
        final b = _map(stroke[i + 1]);
        final steps = math.max(1, ((b - a).distance / 16).ceil());
        for (var s = 0; s <= steps; s++) {
          samples.add(Offset.lerp(a, b, s / steps)!);
        }
      }
    }
    if (samples.isEmpty) return;
    var hit = 0;
    for (final sample in samples) {
      for (final dot in _ink) {
        if ((dot.point - sample).distance < 36) {
          hit++;
          break;
        }
      }
    }
    if (hit / samples.length >= 0.62) {
      setState(() => _done = true);
      _finished++;
      final bucket = _mode == 0 ? 'letters' : 'numbers';
      AppStore.instance.markLearned(bucket, _glyph.label);
      Speaker.say('Wonderful. ${_glyph.spoken}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8FD4EA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              SizedBox(
                width: 108,
                child: Column(
                  children: [
                    _ModeButton(label: 'ENGLISH', color: const Color(0xFF3EC6D6), selected: _mode == 0, onTap: () => _switchMode(0)),
                    const SizedBox(height: 10),
                    _ModeButton(label: 'NUMBERS', color: const Color(0xFFF28C28), selected: _mode == 1, onTap: () => _switchMode(1)),
                    const Spacer(),
                    _RoundButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF2E7D32), width: 6),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            _board = Size(constraints.maxWidth, constraints.maxHeight);
                            final start = _map(_glyph.strokes.first.first);
                            return GestureDetector(
                              onPanStart: _onStart,
                              onPanUpdate: _onMove,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _BoardPainter(
                                        glyph: _glyph,
                                        ink: _ink,
                                        showNumbers: _mode == 1,
                                        done: _done,
                                      ),
                                    ),
                                  ),
                                  if (!_drew)
                                    Positioned(
                                      left: (start.dx - 6).clamp(0, constraints.maxWidth - 40),
                                      top: (start.dy + 4).clamp(0, constraints.maxHeight - 40),
                                      child: const Text('👆', style: TextStyle(fontSize: 34)),
                                    ),
                                  if (_done)
                                    const Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text('Wonderful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ArrowButton(forward: false, onTap: () => _go(-1)),
                        const SizedBox(width: 28),
                        _ArrowButton(forward: true, onTap: () => _go(1)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 72,
                child: Column(
                  children: [
                    const Spacer(),
                    for (final color in _crayons) ...[
                      _Crayon(
                        color: color,
                        selected: color == _crayon,
                        onTap: () => setState(() => _crayon = color),
                      ),
                      const SizedBox(height: 8),
                    ],
                    _RoundButton(
                      icon: Icons.help_outline,
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('How to trace'),
                            content: const Text('Put your finger on the hand. Follow the dots and the arrows. English is letters. Numbers are 0 to 9.'),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _RoundButton(icon: Icons.arrow_forward, onTap: () => _go(1)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? Colors.white : Colors.white24, width: selected ? 3 : 1),
        ),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF607D8B),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: Colors.white, size: 22)),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final bool forward;
  final VoidCallback onTap;
  const _ArrowButton({required this.forward, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF3E0),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF28C28), width: 2),
          ),
          child: Icon(forward ? Icons.arrow_forward : Icons.arrow_back, color: const Color(0xFFF28C28)),
        ),
      ),
    );
  }
}

class _Crayon extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _Crayon({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: selected ? 36 : 30,
        height: selected ? 58 : 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)),
          border: Border.all(color: selected ? Colors.white : Colors.black26, width: selected ? 3 : 1),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final TraceGlyph glyph;
  final List<_Ink> ink;
  final bool showNumbers;
  final bool done;

  _BoardPainter({required this.glyph, required this.ink, required this.showNumbers, required this.done});

  Offset _map(Offset unit, Size size) {
    const pad = 0.12;
    return Offset(
      size.width * (pad + unit.dx * (1 - pad * 2)),
      size.height * (pad + unit.dy * (1 - pad * 2)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final width = math.min(size.width, size.height) * 0.16;
    for (var n = 0; n < glyph.strokes.length; n++) {
      final stroke = glyph.strokes[n];
      final path = Path();
      for (var i = 0; i < stroke.length; i++) {
        final point = _map(stroke[i], size);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = done ? const Color(0xFF8BC34A) : glyph.road
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      _dotsAndArrow(canvas, stroke, size, width);
      if (showNumbers) {
        final start = _map(stroke.first, size);
        _numberBadge(canvas, start, '${n + 1}');
      }
    }

    if (ink.length > 1) {
      for (var i = 1; i < ink.length; i++) {
        canvas.drawLine(
          ink[i - 1].point,
          ink[i].point,
          Paint()
            ..color = ink[i].color.withValues(alpha: 0.9)
            ..strokeWidth = width * 0.55
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  void _dotsAndArrow(Canvas canvas, List<Offset> stroke, Size size, double width) {
    final points = [for (final unit in stroke) _map(unit, size)];
    var travelled = 0.0;
    var nextDot = 0.0;
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final length = (b - a).distance;
      while (nextDot <= travelled + length) {
        final t = length == 0 ? 0.0 : (nextDot - travelled) / length;
        final spot = Offset.lerp(a, b, t.clamp(0, 1))!;
        canvas.drawCircle(spot, math.max(3.5, width * 0.09), Paint()..color = Colors.white);
        nextDot += width * 0.42;
      }
      travelled += length;
    }
    if (points.length >= 2) {
      final end = points.last;
      final prev = points[points.length - 2];
      _arrow(canvas, prev, end);
    }
  }

  void _arrow(Canvas canvas, Offset from, Offset to) {
    final delta = to - from;
    final length = delta.distance;
    if (length < 1) return;
    final direction = delta / length;
    final tip = to;
    final base = tip - direction * 16;
    final side = Offset(-direction.dy, direction.dx) * 8;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + side.dx, base.dy + side.dy)
      ..lineTo(base.dx - side.dx, base.dy - side.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  void _numberBadge(Canvas canvas, Offset at, String text) {
    canvas.drawCircle(at, 12, Paint()..color = Colors.white);
    final painter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Color(0xFF455A64), fontSize: 12, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';

class TraceGlyph {
  final String label;
  final String spoken;
  final List<List<Offset>> strokes;
  final Color road;

  const TraceGlyph({
    required this.label,
    required this.spoken,
    required this.strokes,
    required this.road,
  });
}

List<Offset> _s(List<double> pairs) {
  final points = <Offset>[];
  for (var i = 0; i < pairs.length; i += 2) {
    points.add(Offset(pairs[i] / 100, pairs[i + 1] / 100));
  }
  return points;
}

const _orange = Color(0xFFFFB300);
const _green = Color(0xFF8BC34A);
const _purple = Color(0xFF7E8CFF);
const _blue = Color(0xFF4FC3F7);

final List<TraceGlyph> englishGlyphs = [
  TraceGlyph(label: 'A', spoken: 'A for Apple', road: _orange, strokes: [
    _s([50, 8, 16, 92]),
    _s([50, 8, 84, 92]),
    _s([30, 58, 70, 58]),
  ]),
  TraceGlyph(label: 'B', spoken: 'B for Ball', road: _green, strokes: [
    _s([28, 8, 28, 92]),
    _s([28, 8, 58, 8, 74, 24, 58, 48, 28, 48]),
    _s([28, 48, 64, 48, 80, 68, 62, 92, 28, 92]),
  ]),
  TraceGlyph(label: 'C', spoken: 'C for Cat', road: _purple, strokes: [
    _s([74, 24, 50, 8, 24, 22, 14, 50, 24, 78, 50, 92, 74, 76]),
  ]),
  TraceGlyph(label: 'D', spoken: 'D for Dog', road: _blue, strokes: [
    _s([28, 8, 28, 92]),
    _s([28, 8, 58, 10, 82, 32, 84, 50, 80, 72, 56, 90, 28, 92]),
  ]),
  TraceGlyph(label: 'E', spoken: 'E for Egg', road: _purple, strokes: [
    _s([30, 10, 30, 90]),
    _s([30, 10, 78, 10]),
    _s([30, 50, 68, 50]),
    _s([30, 90, 78, 90]),
  ]),
  TraceGlyph(label: 'F', spoken: 'F for Fish', road: _orange, strokes: [
    _s([32, 10, 32, 90]),
    _s([32, 10, 80, 10]),
    _s([32, 48, 70, 48]),
  ]),
  TraceGlyph(label: 'G', spoken: 'G for Goat', road: _green, strokes: [
    _s([74, 24, 50, 8, 24, 24, 14, 50, 26, 80, 52, 92, 74, 80, 74, 52, 52, 52]),
  ]),
  TraceGlyph(label: 'H', spoken: 'H for Hat', road: _blue, strokes: [
    _s([26, 8, 26, 92]),
    _s([74, 8, 74, 92]),
    _s([26, 50, 74, 50]),
  ]),
  TraceGlyph(label: 'I', spoken: 'I for Igloo', road: _orange, strokes: [
    _s([32, 10, 68, 10]),
    _s([50, 10, 50, 90]),
    _s([32, 90, 68, 90]),
  ]),
  TraceGlyph(label: 'J', spoken: 'J for Jam', road: _purple, strokes: [
    _s([36, 10, 74, 10]),
    _s([62, 10, 62, 70, 48, 90, 28, 76]),
  ]),
  TraceGlyph(label: 'K', spoken: 'K for Kite', road: _green, strokes: [
    _s([30, 8, 30, 92]),
    _s([72, 12, 30, 50]),
    _s([34, 46, 76, 92]),
  ]),
  TraceGlyph(label: 'L', spoken: 'L for Lion', road: _blue, strokes: [
    _s([30, 8, 30, 88, 80, 88]),
  ]),
  TraceGlyph(label: 'M', spoken: 'M for Moon', road: _orange, strokes: [
    _s([16, 92, 16, 14]),
    _s([16, 14, 50, 58, 84, 14]),
    _s([84, 14, 84, 92]),
  ]),
  TraceGlyph(label: 'N', spoken: 'N for Nest', road: _green, strokes: [
    _s([22, 92, 22, 12]),
    _s([22, 12, 78, 92]),
    _s([78, 92, 78, 12]),
  ]),
  TraceGlyph(label: 'O', spoken: 'O for Orange', road: _purple, strokes: [
    _s([50, 8, 78, 18, 90, 50, 78, 82, 50, 92, 22, 82, 10, 50, 22, 18, 50, 8]),
  ]),
  TraceGlyph(label: 'P', spoken: 'P for Pig', road: _blue, strokes: [
    _s([30, 8, 30, 92]),
    _s([30, 8, 62, 8, 80, 26, 62, 48, 30, 48]),
  ]),
  TraceGlyph(label: 'Q', spoken: 'Q for Queen', road: _orange, strokes: [
    _s([50, 8, 78, 18, 90, 50, 78, 82, 50, 92, 22, 82, 10, 50, 22, 18, 50, 8]),
    _s([62, 68, 84, 92]),
  ]),
  TraceGlyph(label: 'R', spoken: 'R for Rain', road: _green, strokes: [
    _s([28, 8, 28, 92]),
    _s([28, 8, 60, 8, 78, 26, 58, 48, 28, 48]),
    _s([48, 48, 80, 92]),
  ]),
  TraceGlyph(label: 'S', spoken: 'S for Sun', road: _purple, strokes: [
    _s([76, 22, 56, 8, 30, 16, 20, 34, 38, 48, 66, 56, 78, 72, 62, 90, 34, 90, 18, 74]),
  ]),
  TraceGlyph(label: 'T', spoken: 'T for Tiger', road: _blue, strokes: [
    _s([18, 12, 82, 12]),
    _s([50, 12, 50, 90]),
  ]),
  TraceGlyph(label: 'U', spoken: 'U for Umbrella', road: _orange, strokes: [
    _s([22, 10, 22, 62, 36, 88, 64, 88, 78, 62, 78, 10]),
  ]),
  TraceGlyph(label: 'V', spoken: 'V for Van', road: _green, strokes: [
    _s([16, 10, 50, 90]),
    _s([84, 10, 50, 90]),
  ]),
  TraceGlyph(label: 'W', spoken: 'W for Water', road: _purple, strokes: [
    _s([10, 10, 28, 90]),
    _s([28, 90, 50, 28]),
    _s([50, 28, 72, 90]),
    _s([72, 90, 90, 10]),
  ]),
  TraceGlyph(label: 'X', spoken: 'X for Box', road: _blue, strokes: [
    _s([18, 12, 82, 88]),
    _s([82, 12, 18, 88]),
  ]),
  TraceGlyph(label: 'Y', spoken: 'Y for Yo-yo', road: _orange, strokes: [
    _s([16, 10, 50, 48]),
    _s([84, 10, 50, 48, 50, 90]),
  ]),
  TraceGlyph(label: 'Z', spoken: 'Z for Zebra', road: _green, strokes: [
    _s([18, 14, 82, 14]),
    _s([82, 14, 18, 86]),
    _s([18, 86, 82, 86]),
  ]),
];

final List<TraceGlyph> numberGlyphs = [
  TraceGlyph(label: '0', spoken: 'Zero', road: _green, strokes: [
    _s([50, 8, 78, 18, 90, 50, 78, 82, 50, 92, 22, 82, 10, 50, 22, 18, 50, 8]),
  ]),
  TraceGlyph(label: '1', spoken: 'One', road: _orange, strokes: [
    _s([36, 30, 54, 10, 54, 88]),
    _s([34, 88, 74, 88]),
  ]),
  TraceGlyph(label: '2', spoken: 'Two', road: _purple, strokes: [
    _s([26, 32, 38, 12, 60, 10, 78, 26, 68, 46, 24, 80, 22, 90, 80, 90]),
  ]),
  TraceGlyph(label: '3', spoken: 'Three', road: _blue, strokes: [
    _s([24, 22, 42, 8, 68, 14, 78, 32, 58, 48]),
    _s([46, 48, 72, 52, 82, 70, 66, 90, 38, 92, 20, 76]),
  ]),
  TraceGlyph(label: '4', spoken: 'Four', road: _orange, strokes: [
    _s([66, 10, 22, 58, 82, 58]),
    _s([66, 10, 66, 92]),
  ]),
  TraceGlyph(label: '5', spoken: 'Five', road: _green, strokes: [
    _s([74, 12, 28, 12, 26, 42]),
    _s([26, 42, 52, 36, 76, 50, 76, 70, 58, 90, 30, 88, 18, 70]),
  ]),
  TraceGlyph(label: '6', spoken: 'Six', road: _purple, strokes: [
    _s([70, 18, 46, 8, 24, 26, 16, 52, 22, 76, 44, 92, 66, 84, 76, 64, 62, 48, 38, 50, 22, 62]),
  ]),
  TraceGlyph(label: '7', spoken: 'Seven', road: _blue, strokes: [
    _s([20, 14, 80, 14, 40, 90]),
  ]),
  TraceGlyph(label: '8', spoken: 'Eight', road: _orange, strokes: [
    _s([50, 48, 28, 36, 28, 16, 50, 8, 72, 16, 70, 36, 50, 48]),
    _s([50, 48, 76, 64, 72, 88, 50, 94, 28, 86, 26, 64, 50, 48]),
  ]),
  TraceGlyph(label: '9', spoken: 'Nine', road: _green, strokes: [
    _s([62, 34, 46, 12, 26, 22, 20, 42, 36, 58, 58, 52, 68, 34]),
    _s([62, 34, 70, 58, 62, 84, 42, 94]),
  ]),
];

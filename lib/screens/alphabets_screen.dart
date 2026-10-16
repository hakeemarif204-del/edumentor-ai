import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/speaker.dart';

class AlphabetsScreen extends StatefulWidget {
  const AlphabetsScreen({super.key});

  @override
  State<AlphabetsScreen> createState() => _AlphabetsScreenState();
}

class _AlphabetsScreenState extends State<AlphabetsScreen> {
  final PageController _pageController = PageController();
  final Set<String> _seen = {};
  int _currentIndex = 0;
  bool _saved = false;

  // Each entry: letter, example word, emoji for that word
  final List<_LetterData> _letters = const [
    _LetterData('A', 'Apple', '🍎'),
    _LetterData('B', 'Ball', '⚽'),
    _LetterData('C', 'Cat', '🐱'),
    _LetterData('D', 'Dog', '🐶'),
    _LetterData('E', 'Elephant', '🐘'),
    _LetterData('F', 'Fish', '🐟'),
    _LetterData('G', 'Grapes', '🍇'),
    _LetterData('H', 'Hat', '🎩'),
    _LetterData('I', 'Ice cream', '🍦'),
    _LetterData('J', 'Juice', '🧃'),
    _LetterData('K', 'Kite', '🪁'),
    _LetterData('L', 'Lion', '🦁'),
    _LetterData('M', 'Moon', '🌙'),
    _LetterData('N', 'Nest', '🪺'),
    _LetterData('O', 'Orange', '🍊'),
    _LetterData('P', 'Parrot', '🦜'),
    _LetterData('Q', 'Queen', '👑'),
    _LetterData('R', 'Rainbow', '🌈'),
    _LetterData('S', 'Sun', '☀️'),
    _LetterData('T', 'Tiger', '🐯'),
    _LetterData('U', 'Umbrella', '☂️'),
    _LetterData('V', 'Van', '🚐'),
    _LetterData('W', 'Watermelon', '🍉'),
    _LetterData('X', 'Xylophone', '🎼'),
    _LetterData('Y', 'Yoyo', '🪀'),
    _LetterData('Z', 'Zebra', '🦓'),
  ];

  @override
  void initState() {
    super.initState();
    _noteLetter(0);
  }

  void _noteLetter(int index) {
    final letter = _letters[index].letter;
    _seen.add(letter);
    AppStore.instance.markLearned('letters', letter);
  }

  @override
  void dispose() {
    if (!_saved && _seen.isNotEmpty) {
      _saved = true;
      AppStore.instance.recordActivity(
        subject: 'Alphabets',
        title: 'Alphabet cards',
        score: ((_seen.length / _letters.length) * 100).round(),
        stars: _seen.length >= 10 ? 3 : _seen.length >= 4 ? 2 : 1,
      );
    }
    Speaker.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index >= 0 && index < _letters.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Speaks just the current letter (background tap, letter tap).
  Future<void> _speakLetterOnly() async {
    final letter = _letters[_currentIndex];
    await Speaker.say(letter.letter);
  }

  /// Speaks the full phrase, e.g. "A for Apple" (picture tap).
  Future<void> _speakFullPhrase() async {
    final letter = _letters[_currentIndex];
    await Speaker.say('${letter.letter} for ${letter.word}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        title: const Text('Alphabets'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Letter ${_currentIndex + 1} of ${_letters.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _letters.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _noteLetter(index);
              },
              itemBuilder: (context, index) {
                final letter = _letters[index];
                return _FlashCard(
                  letter: letter,
                  onGeneralTap: _speakLetterOnly,
                  onPictureTap: _speakFullPhrase,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: _currentIndex == 0 ? null : () => _goTo(_currentIndex - 1),
                ),
                _NavButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: _currentIndex == _letters.length - 1
                      ? null
                      : () => _goTo(_currentIndex + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterData {
  final String letter;
  final String word;
  final String emoji;
  const _LetterData(this.letter, this.word, this.emoji);
}

/// The main learning card. The whole card speaks the letter on tap;
/// the picture (inside its own bouncy tap target) speaks the full phrase.
/// Because Flutter's gesture arena only lets one recognizer win a tap,
/// tapping the picture does NOT also trigger the card's general tap.
class _FlashCard extends StatelessWidget {
  final _LetterData letter;
  final VoidCallback onGeneralTap;
  final VoidCallback onPictureTap;

  const _FlashCard({
    required this.letter,
    required this.onGeneralTap,
    required this.onPictureTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onGeneralTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BouncyTap(
                onTap: onGeneralTap,
                child: Text(
                  letter.letter,
                  style: const TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _BouncyTap(
                onTap: onPictureTap,
                child: Text(letter.emoji, style: const TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 12),
              Text(
                '${letter.letter} for ${letter.word}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wraps a child with a tap target that gives a quick bounce/scale
/// animation for immediate visual feedback, then fires [onTap].
class _BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyTap({required this.child, required this.onTap});

  @override
  State<_BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<_BouncyTap> {
  double _scale = 1.0;

  void _setScale(double value) => setState(() => _scale = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.88),
      onTapUp: (_) {
        _setScale(1.0);
        widget.onTap();
      },
      onTapCancel: () => _setScale(1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  const _NavButton({required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: isPrimary ? 30 : 24,
        backgroundColor: !enabled
            ? Colors.grey[300]
            : isPrimary
                ? Colors.deepPurple
                : Colors.white,
        child: Icon(
          icon,
          color: !enabled
              ? Colors.grey[500]
              : isPrimary
                  ? Colors.white
                  : Colors.deepPurple,
        ),
      ),
    );
  }
}
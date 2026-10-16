import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/speaker.dart';

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key});

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  final PageController _pageController = PageController();
  final Set<String> _seen = {};
  int _currentIndex = 0;
  bool _saved = false;

  // Each entry: number, a different animal emoji per number
  final List<_NumberData> _numbers = const [
    _NumberData(1, '🦁'),
    _NumberData(2, '🐘'),
    _NumberData(3, '🐊'),
    _NumberData(4, '🦒'),
    _NumberData(5, '🐒'),
    _NumberData(6, '🦓'),
    _NumberData(7, '🦌'),
    _NumberData(8, '🐆'),
    _NumberData(9, '🐅'),
    _NumberData(10, '🐼'),
  ];

  @override
  void initState() {
    super.initState();
    _note(0);
  }

  void _note(int index) {
    final value = _numbers[index].value.toString();
    _seen.add(value);
    AppStore.instance.markLearned('numbers', value);
  }

  @override
  void dispose() {
    if (!_saved && _seen.isNotEmpty) {
      _saved = true;
      AppStore.instance.recordActivity(
        subject: 'Numbers',
        title: 'Counting 1-10',
        score: ((_seen.length / _numbers.length) * 100).round(),
        stars: _seen.length >= 10 ? 3 : _seen.length >= 4 ? 2 : 1,
      );
    }
    Speaker.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index >= 0 && index < _numbers.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        title: const Text('Numbers'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            'Number ${_currentIndex + 1} of ${_numbers.length}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _numbers.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _note(index);
              },
              itemBuilder: (context, index) {
                final number = _numbers[index];
                return _NumberCard(number: number);
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
                  icon: Icons.volume_up,
                  onTap: () {
                    final number = _numbers[_currentIndex];
                    Speaker.say('${number.value}');
                  },
                  isPrimary: true,
                ),
                _NavButton(
                  icon: Icons.arrow_forward_ios,
                  onTap: _currentIndex == _numbers.length - 1
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

class _NumberData {
  final int value;
  final String emoji;
  const _NumberData(this.value, this.emoji);
}

class _NumberCard extends StatelessWidget {
  final _NumberData number;
  const _NumberCard({required this.number});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF8FD3F4),
                  Color(0xFFA8E063),
                ],
                stops: [0.45, 0.45],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD9A066),
                    border: Border.all(color: const Color(0xFF8B5A2B), width: 4),
                  ),
                  child: Center(
                    child: Text(
                      '${number.value}',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF5B3A1E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      number.value,
                      (i) => Text(number.emoji, style: const TextStyle(fontSize: 44)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
                ? Colors.green[700]
                : Colors.white,
        child: Icon(
          icon,
          color: !enabled
              ? Colors.grey[500]
              : isPrimary
                  ? Colors.white
                  : Colors.green[700],
        ),
      ),
    );
  }
}
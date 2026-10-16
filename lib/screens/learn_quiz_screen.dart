import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/speaker.dart';

class LessonItem {
  final String id;
  final String name;
  final String emoji;
  final String speech;
  final String? fact;

  const LessonItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.speech,
    this.fact,
  });
}

class LearnQuizScreen extends StatefulWidget {
  final String subject;
  final String title;
  final String learnedBucket;
  final Color accent;
  final List<LessonItem> items;

  const LearnQuizScreen({
    super.key,
    required this.subject,
    required this.title,
    required this.learnedBucket,
    required this.accent,
    required this.items,
  });

  @override
  State<LearnQuizScreen> createState() => _LearnQuizScreenState();
}

class _LearnQuizScreenState extends State<LearnQuizScreen> {
  final PageController _pageController = PageController();
  final Set<String> _seen = {};
  int _index = 0;
  bool _quizzing = false;
  int _question = 0;
  int _correct = 0;
  late List<_Round> _rounds;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _seen.add(widget.items.first.id);
    _rounds = _buildRounds();
  }

  @override
  void dispose() {
    _saveVisit();
    _pageController.dispose();
    super.dispose();
  }

  void _saveVisit() {
    if (_saved || _quizzing) return;
    _saved = true;
    final score = ((_seen.length / widget.items.length) * 100).round();
    AppStore.instance.recordActivity(
      subject: widget.subject,
      title: '${widget.title} cards',
      score: score,
      stars: _seen.length >= widget.items.length ? 2 : 1,
    );
  }

  List<_Round> _buildRounds() {
    final random = Random();
    final items = [...widget.items]..shuffle(random);
    return items.take(min(6, items.length)).map((item) {
      final others = widget.items.where((entry) => entry.id != item.id).toList()..shuffle(random);
      final options = [item, ...others.take(3)]..shuffle(random);
      return _Round(item, options);
    }).toList();
  }

  Future<void> _speakCurrent() async {
    await Speaker.say(widget.items[_index].speech);
  }

  void _startQuiz() {
    _saveVisit();
    setState(() {
      _quizzing = true;
      _question = 0;
      _correct = 0;
      _rounds = _buildRounds();
      _saved = false;
    });
  }

  void _answer(LessonItem choice) {
    final round = _rounds[_question];
    final right = choice.id == round.item.id;
    if (right) {
      _correct++;
      AppStore.instance.markLearned(widget.learnedBucket, round.item.id);
    }
    Speaker.say(right ? 'Yes! ${round.item.name}' : 'This is ${round.item.name}');
    if (_question + 1 >= _rounds.length) {
      _finishQuiz();
      return;
    }
    setState(() => _question++);
  }

  void _finishQuiz() {
    final total = _rounds.length;
    final score = ((_correct / total) * 100).round();
    final stars = _correct == total ? 3 : _correct >= total - 1 ? 2 : _correct >= (total / 2) ? 1 : 0;
    _saved = true;
    AppStore.instance.recordActivity(
      subject: widget.subject,
      title: '${widget.title} quiz',
      score: score,
      stars: stars,
    );
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(stars > 0 ? 'Well done!' : 'Good try!'),
        content: Text('You got $_correct out of $total.\n${stars > 0 ? '⭐' * stars : 'Let\'s practice again.'}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startQuiz();
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizzing) return _buildQuiz();
    final item = widget.items[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _startQuiz,
            child: const Text('Quiz', style: TextStyle(color: Color(0xFF6B4EFF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text('${_index + 1} of ${widget.items.length}', style: const TextStyle(color: Colors.black54)),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() => _index = index);
                _seen.add(widget.items[index].id);
              },
              itemBuilder: (context, index) {
                final card = widget.items[index];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _speakCurrent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(card.emoji, style: const TextStyle(fontSize: 92)),
                          const SizedBox(height: 12),
                          Text(card.name, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: widget.accent)),
                          if (card.fact != null) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(card.fact!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.4)),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Text('Tap to hear', style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                IconButton.filled(
                  onPressed: _index == 0 ? null : () => _pageController.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _speakCurrent,
                  icon: const Icon(Icons.volume_up),
                  label: Text(item.name),
                  style: FilledButton.styleFrom(backgroundColor: widget.accent),
                ),
                const Spacer(),
                IconButton.filled(
                  onPressed: _index == widget.items.length - 1
                      ? null
                      : () => _pageController.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final round = _rounds[_question];
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        title: Text('${widget.title} quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(value: _question / _rounds.length, color: widget.accent, backgroundColor: Colors.white),
            const SizedBox(height: 24),
            const Text('What is this?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(round.item.emoji, style: const TextStyle(fontSize: 96)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  for (final option in round.options)
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _answer(option),
                        child: Center(
                          child: Text(option.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
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

class _Round {
  final LessonItem item;
  final List<LessonItem> options;
  const _Round(this.item, this.options);
}

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/mentor.dart';
import '../data/speaker.dart';
import '../theme/kid_theme.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({super.key});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  String? _question;
  String? _answer;
  bool _listening = false;
  bool _micReady = false;
  bool _thinking = false;

  static const _chips = [
    'How am I doing?',
    'Teach me a letter',
    'Count to 5',
    '2 plus 1',
    'What colour is the sun?',
    'What is a circle?',
  ];

  @override
  void initState() {
    super.initState();
    _prepareMic();
  }

  Future<void> _prepareMic() async {
    try {
      final ready = await _speech.initialize();
      if (mounted) setState(() => _micReady = ready);
    } catch (_) {
      if (mounted) setState(() => _micReady = false);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleMic() async {
    if (!_micReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The microphone is not ready. You can type instead.')),
      );
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      await _ask();
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (result) {
        _controller.text = result.recognizedWords;
        if (result.finalResult && mounted) {
          setState(() => _listening = false);
          _ask();
        }
      },
    );
  }

  Future<void> _ask([String? preset]) async {
    final question = (preset ?? _controller.text).trim();
    if (question.isEmpty) return;
    _controller.text = question;
    setState(() {
      _thinking = true;
      _question = question;
      _answer = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final reply = Mentor.teach(question);
    if (!mounted) return;
    setState(() {
      _thinking = false;
      _answer = reply;
    });
    await Speaker.say(reply);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KidColors.cream,
      appBar: AppBar(title: const Text('Your teacher')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const KidIntro(
            emoji: '🤖',
            title: 'I am here to help',
            message: 'Ask me to count, say a letter, or name a colour. I will say it with you.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in _chips)
                ActionChip(label: Text(chip), onPressed: () => _ask(chip)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _ask(),
            decoration: InputDecoration(
              hintText: _listening ? 'I am listening...' : 'Ask a little question',
              suffixIcon: IconButton(
                onPressed: _toggleMic,
                icon: Icon(_listening ? Icons.stop_circle : Icons.mic, color: KidColors.plum),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => _ask(), child: const Text('Ask')),
          const SizedBox(height: 20),
          if (_question != null)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: KidColors.plum,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(_question!, style: const TextStyle(color: Colors.white, height: 1.3)),
              ),
            ),
          if (_thinking)
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
            ),
          if (_answer != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Text(_answer!, style: const TextStyle(fontSize: 16, height: 1.45, color: KidColors.ink)),
            ),
        ],
      ),
    );
  }
}

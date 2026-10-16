import 'package:flutter/material.dart';

import '../data/mentor.dart';

class AiInsightsTab extends StatefulWidget {
  final String childName;

  const AiInsightsTab({super.key, required this.childName});

  @override
  State<AiInsightsTab> createState() => _AiInsightsTabState();
}

class _AiInsightsTabState extends State<AiInsightsTab> {
  final TextEditingController _questionController = TextEditingController();
  String? _answer;
  bool _isThinking = false;

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;
    setState(() {
      _isThinking = true;
      _answer = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _isThinking = false;
      _answer = Mentor.answer(question);
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strengths = Mentor.strengths();
    final practice = Mentor.needsPractice();
    final tips = Mentor.recommendations();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('AI Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
        const SizedBox(height: 8),
        Text(Mentor.summary(), style: const TextStyle(height: 1.4)),
        const SizedBox(height: 16),
        const Text('Strengths', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (final item in strengths) _BulletRow(item),
        const SizedBox(height: 12),
        const Text('Needs practice', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (final item in practice) _BulletRow(item),
        const SizedBox(height: 12),
        const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        for (final item in tips) _BulletRow(item),
        const SizedBox(height: 16),
        TextField(
          controller: _questionController,
          decoration: InputDecoration(
            hintText: 'Ask about ${widget.childName}',
            filled: true,
            fillColor: const Color(0xFFFFF6EE),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
          onSubmitted: (_) => _askQuestion(),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(onPressed: _askQuestion, child: const Text('Ask')),
        ),
        if (_isThinking) const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator())),
        if (_answer != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(16)),
            child: Text(_answer!, style: const TextStyle(height: 1.4)),
          ),
      ],
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

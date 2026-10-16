import 'package:flutter/material.dart';

import '../data/app_store.dart';

class ProgressAnalyticsTab extends StatelessWidget {
  final String childName;
  final int childAge;

  const ProgressAnalyticsTab({
    super.key,
    required this.childName,
    required this.childAge,
  });

  @override
  Widget build(BuildContext context) {
    final stats = AppStore.instance.statsFor(AppStore.instance.activeChild.id);
    final subjects = [
      _SubjectScore('Alphabet', stats.subjectScores['Alphabets'] ?? (stats.lettersLearned / 26), const Color(0xFF6B4EFF)),
      _SubjectScore('Numbers', stats.subjectScores['Numbers'] ?? (stats.numbersLearned / 10), const Color(0xFFFF9800)),
      _SubjectScore('Colours', stats.subjectScores['Colours'] ?? (stats.coloursLearned / 8), const Color(0xFFE91E63)),
      _SubjectScore('Shapes', stats.subjectScores['Shapes'] ?? (stats.shapesLearned / 8), const Color(0xFF2196F3)),
      _SubjectScore('Rhymes', stats.subjectScores['Rhymes'] ?? 0, const Color(0xFF673AB7)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A)),
          ),
          Text('$childName — $childAge years', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatCard(emoji: '🔤', value: '${stats.lettersLearned}/26', label: 'Letters Learned', color: const Color(0xFFF3E5F5)),
              _StatCard(emoji: '🔢', value: '${stats.numbersLearned}/10', label: 'Numbers Learned', color: const Color(0xFFFFF3E0)),
              _StatCard(emoji: '🔺', value: '${stats.shapesLearned}/8', label: 'Shapes Mastered', color: const Color(0xFFE3F2FD)),
              _StatCard(emoji: '🎨', value: '${stats.coloursLearned}/8', label: 'Colours Explored', color: const Color(0xFFFCE4EC)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Overall Learning Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: stats.overall,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF6B4EFF),
                  ),
                ),
                Text('${(stats.overall * 100).round()}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Learning Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActivityChip(icon: Icons.videogame_asset, label: 'Games Played', value: '${stats.gamesPlayed}'),
              _ActivityChip(icon: Icons.menu_book, label: 'Stories Completed', value: '${stats.storiesCompleted}'),
              _ActivityChip(icon: Icons.check_circle_outline, label: 'Activities Completed', value: '${stats.activitiesCompleted}'),
              _ActivityChip(icon: Icons.star, label: 'Stars Earned', value: '${stats.stars}'),
              _ActivityChip(icon: Icons.local_fire_department, label: 'Learning Streak', value: '${stats.streak} days'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Weekly Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20,
                      height: 8 + 82 * stats.weekly[index],
                      decoration: BoxDecoration(color: const Color(0xFF6B4EFF), borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(height: 6),
                    Text(weekDays[index], style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Subject Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...subjects.map((subject) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(subject.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${(subject.score * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: subject.score.clamp(0, 1),
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: subject.color,
                      ),
                    ),
                  ],
                ),
              )),
          if (stats.activitiesCompleted == 0)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Play an activity and these numbers will fill in.', style: TextStyle(color: Colors.black54)),
            ),
        ],
      ),
    );
  }
}

const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class _SubjectScore {
  final String name;
  final double score;
  final Color color;
  const _SubjectScore(this.name, this.score, this.color);
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _StatCard({required this.emoji, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ActivityChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFFFF6EE), borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B4EFF)),
          const SizedBox(width: 6),
          Text('$value ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

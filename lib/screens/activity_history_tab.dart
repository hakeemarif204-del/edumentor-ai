import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';

class ActivityHistoryTab extends StatefulWidget {
  const ActivityHistoryTab({super.key});

  @override
  State<ActivityHistoryTab> createState() => _ActivityHistoryTabState();
}

class _ActivityHistoryTabState extends State<ActivityHistoryTab> {
  String _timeFilter = 'Today';
  String _subjectFilter = 'All';

  static const List<String> _timeFilters = ['Today', 'This Week', 'This Month', 'All Activities'];
  static const List<String> _subjectFilters = [
    'All',
    'Alphabets',
    'Numbers',
    'Colours',
    'Shapes',
    'Rhymes',
    'Stories',
    'Games',
    'Matching',
    'Colouring',
    'Science',
  ];

  bool _matchesTime(DateTime at) {
    final now = DateTime.now();
    if (_timeFilter == 'All Activities') return true;
    if (_timeFilter == 'Today') return dayKey(at) == dayKey(now);
    if (_timeFilter == 'This Week') return now.difference(at).inDays < 7;
    return at.year == now.year && at.month == now.month;
  }

  String _groupLabel(DateTime at) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${at.day}/${at.month}/${at.year}';
  }

  @override
  Widget build(BuildContext context) {
    final items = AppStore.instance.activities.where((item) {
      return item.childId == AppStore.instance.activeChild.id &&
          _matchesTime(item.at) &&
          (_subjectFilter == 'All' || item.subject == _subjectFilter);
    }).toList();

    final grouped = <String, List<ActivityRecord>>{};
    for (final item in items) {
      grouped.putIfAbsent(_groupLabel(item.at), () => []).add(item);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📚 Activity History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _timeFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _timeFilters[index];
                final selected = filter == _timeFilter;
                return ChoiceChip(
                  label: Text(filter, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => setState(() => _timeFilter = filter),
                  selectedColor: const Color(0xFF6B4EFF),
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _subjectFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _subjectFilters[index];
                final selected = filter == _subjectFilter;
                return ChoiceChip(
                  label: Text(filter, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => setState(() => _subjectFilter = filter),
                  selectedColor: const Color(0xFFFF9800),
                  labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: grouped.isEmpty
                ? const Center(child: Text('No activities for this filter yet.'))
                : ListView(
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                          ),
                          ...entry.value.map((activity) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Text(subjectEmojis[activity.subject] ?? '⭐', style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Text('${activity.stars} stars', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                                      child: Text('${activity.score}%', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

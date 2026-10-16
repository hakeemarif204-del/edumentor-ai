import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';

class GoalsTab extends StatefulWidget {
  const GoalsTab({super.key});

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  static const List<Map<String, String>> _categories = [
    {'emoji': '🔤', 'label': 'Alphabets'},
    {'emoji': '🔢', 'label': 'Numbers'},
    {'emoji': '🎨', 'label': 'Colours'},
    {'emoji': '🔺', 'label': 'Shapes'},
    {'emoji': '🎵', 'label': 'Rhymes'},
    {'emoji': '📖', 'label': 'Stories'},
    {'emoji': '🎮', 'label': 'Games'},
    {'emoji': '🧩', 'label': 'Matching'},
    {'emoji': '🖍️', 'label': 'Colouring'},
    {'emoji': '🧪', 'label': 'Science'},
  ];

  void _openGoalSheet({LearningGoal? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final targetController = TextEditingController(text: '${existing?.target ?? 5}');
    var subject = existing?.subject ?? 'Alphabets';
    var emoji = existing?.subjectEmoji ?? '🔤';
    DateTime? deadline = existing?.deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setSheet) => SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? 'Add goal' : 'Edit goal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Goal')),
              TextField(controller: targetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'How many activities')),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final category in _categories)
                    ChoiceChip(
                      label: Text('${category['emoji']} ${category['label']}'),
                      selected: subject == category['label'],
                      onSelected: (_) => setSheet(() {
                        subject = category['label']!;
                        emoji = category['emoji']!;
                      }),
                    ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: deadline ?? DateTime.now().add(const Duration(days: 7)),
                  );
                  if (picked != null) setSheet(() => deadline = picked);
                },
                child: Text(deadline == null ? 'Add a due date' : 'Due ${deadline!.day}/${deadline!.month}/${deadline!.year}'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  final target = int.tryParse(targetController.text) ?? 1;
                  final goal = LearningGoal(
                    id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    childId: AppStore.instance.activeChild.id,
                    title: titleController.text.trim().isEmpty ? 'New goal' : titleController.text.trim(),
                    subject: subject,
                    subjectEmoji: emoji,
                    target: target < 1 ? 1 : target,
                    createdAt: existing?.createdAt ?? DateTime.now(),
                    deadline: deadline,
                  );
                  if (existing == null) {
                    AppStore.instance.addGoal(goal);
                  } else {
                    AppStore.instance.updateGoal(goal);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final goals = store.goalsForActive();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🎯 Learning Goals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
                    Text('Goals move forward when that subject is played.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _openGoalSheet(),
                icon: const Icon(Icons.add, color: Color(0xFF6B4EFF)),
                label: const Text('Add Goal', style: TextStyle(color: Color(0xFF6B4EFF))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: goals.isEmpty
                ? const Center(child: Text('No goals yet. Tap Add Goal to create one.'))
                : ListView.separated(
                    itemCount: goals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      final current = store.goalCurrent(goal);
                      final progress = goal.target == 0 ? 0.0 : current / goal.target;
                      final done = current >= goal.target;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: done ? const Color(0xFFE8F5E9) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(goal.subjectEmoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                                if (done) const Text('✅'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('$current / ${goal.target}'),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0, 1),
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                color: done ? const Color(0xFF4CAF50) : const Color(0xFF6B4EFF),
                              ),
                            ),
                            if (goal.deadline != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('Due: ${goal.deadline!.day}/${goal.deadline!.month}/${goal.deadline!.year}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: OutlinedButton(onPressed: () => _openGoalSheet(existing: goal), child: const Text('Edit'))),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => store.deleteGoal(goal.id),
                                    child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

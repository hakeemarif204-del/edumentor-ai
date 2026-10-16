import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/models.dart';

class ChildrenProfilesTab extends StatelessWidget {
  const ChildrenProfilesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Children', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
              ),
              TextButton.icon(
                onPressed: () => _editChild(context, null),
                icon: const Icon(Icons.add, color: Color(0xFF6B4EFF)),
                label: const Text('Add', style: TextStyle(color: Color(0xFF6B4EFF))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: store.children.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final child = store.children[index];
                final stats = store.statsFor(child.id);
                final isActive = child.id == store.activeChildId;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFF3E5F5) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isActive ? const Color(0xFF6B4EFF) : Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(child.avatarEmoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${child.name} — ${child.age} years', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Overall ${(stats.overall * 100).round()}% · ${child.level}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFF6B4EFF), borderRadius: BorderRadius.circular(20)),
                              child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('🔥 ${stats.streak} day streak    ⭐ ${stats.stars} stars'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => _showProgress(context, child, stats), child: const Text('Progress', style: TextStyle(fontSize: 12)))),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton(onPressed: () => store.setActiveChild(child.id), child: const Text('Switch', style: TextStyle(fontSize: 12)))),
                          const SizedBox(width: 8),
                          Expanded(child: OutlinedButton(onPressed: () => _editChild(context, child), child: const Text('Edit', style: TextStyle(fontSize: 12)))),
                        ],
                      ),
                      if (store.children.length > 1)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(onPressed: () => store.deleteChild(child.id), child: const Text('Remove', style: TextStyle(color: Colors.redAccent))),
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

  void _showProgress(BuildContext context, ChildProfile child, ChildStats stats) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(child.name),
        content: Text(
          'Letters ${stats.lettersLearned}/26\n'
          'Numbers ${stats.numbersLearned}/10\n'
          'Shapes ${stats.shapesLearned}/8\n'
          'Colours ${stats.coloursLearned}/8\n'
          'Activities ${stats.activitiesCompleted}\n'
          'Stars ${stats.stars}',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _editChild(BuildContext context, ChildProfile? existing) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final ageController = TextEditingController(text: existing == null ? '' : '${existing.age}');
    var avatar = existing?.avatarEmoji ?? '👧';
    var level = existing?.level ?? 'Beginner';
    var focus = existing?.focusSubject ?? 'Alphabets';
    const avatars = ['👧', '👦', '🧒', '🌟', '🐰', '🦁'];
    const levels = ['Beginner', 'Growing', 'Confident'];
    const focuses = ['Alphabets', 'Numbers', 'Shapes', 'Colours', 'Rhymes', 'Stories'];

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
                Text(existing == null ? 'Add child' : 'Edit child', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final item in avatars)
                      ChoiceChip(label: Text(item), selected: avatar == item, onSelected: (_) => setSheet(() => avatar = item)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final item in levels)
                      ChoiceChip(label: Text(item), selected: level == item, onSelected: (_) => setSheet(() => level = item)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Focus subject'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final item in focuses)
                      ChoiceChip(label: Text(item), selected: focus == item, onSelected: (_) => setSheet(() => focus = item)),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    final age = int.tryParse(ageController.text) ?? 4;
                    final child = ChildProfile(
                      id: existing?.id ?? 'child_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim().isEmpty ? 'Little Learner' : nameController.text.trim(),
                      age: age < 1 ? 1 : (age > 12 ? 12 : age),
                      avatarEmoji: avatar,
                      level: level,
                      focusSubject: focus,
                    );
                    if (existing == null) {
                      AppStore.instance.addChild(child);
                    } else {
                      AppStore.instance.updateChild(child);
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
}

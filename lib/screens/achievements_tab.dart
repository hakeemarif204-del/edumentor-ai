import 'package:flutter/material.dart';

import '../data/app_store.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final badges = store.badgesFor(store.activeChild.id);
    final unlocked = badges.where((badge) => badge.unlocked).length;
    final stars = store.statsFor(store.activeChild.id).stars;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆 Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B2A5A))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Pill('$unlocked / ${badges.length} unlocked'),
              _Pill('⭐ $stars stars'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              itemCount: badges.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Opacity(
                  opacity: badge.unlocked ? 1 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: badge.unlocked ? const Color(0xFFF3E5F5) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: badge.unlocked ? const Color(0xFF6B4EFF) : Colors.grey.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(badge.emoji, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(badge.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(badge.description, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.black54)),
                        if (!badge.unlocked) const Icon(Icons.lock_outline, size: 12, color: Colors.black38),
                      ],
                    ),
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

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF3B2A5A))),
    );
  }
}

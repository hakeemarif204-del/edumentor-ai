import 'package:flutter/material.dart';

import '../data/app_store.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final notes = store.notes;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notes.isNotEmpty)
            TextButton(
              onPressed: store.markAllNotesRead,
              child: const Text('Mark all read', style: TextStyle(color: Color(0xFF6B4EFF))),
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final items = store.notes;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔔', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('No notifications yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 6),
                    Text('Stars, goals, and time limits will show up here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = items[index];
              return Dismissible(
                key: ValueKey(note.id),
                onDismissed: (_) => store.deleteNote(note.id),
                child: Material(
                  color: note.isRead ? Colors.white : const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    onTap: () => store.markNoteRead(note.id),
                    leading: Text(note.emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.body),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

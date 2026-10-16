import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/speaker.dart';

class _Story {
  final String id;
  final String title;
  final String emoji;
  final List<String> pages;
  const _Story(this.id, this.title, this.emoji, this.pages);
}

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  static const List<_Story> _stories = [
    _Story('boat', 'The Little Blue Boat', '⛵', [
      'A little blue boat sat by the shore and wanted to see the island.',
      'The wind filled the sail. The boat went past a turtle and a jumping fish.',
      'On the island, a crab waved hello and shared a smooth pebble.',
      'The boat sailed home before sunset, happy and a little bit salty.',
    ]),
    _Story('seed', 'The Seed Who Waited', '🌱', [
      'A small seed lay under the soil and listened to the rain.',
      'Day by day a green tip pushed up toward the light.',
      'Leaves opened. A yellow flower looked at the sun.',
      'A bee stopped by, and the flower felt proud of waiting.',
    ]),
    _Story('kite', 'Kite Day', '🪁', [
      'Amina held a red kite and ran across the grass.',
      'The kite climbed, dipped, and then caught the wind.',
      'It flew beside a bird and waved its long tail.',
      'When the wind rested, the kite came down for a hug.',
    ]),
    _Story('star', 'The Lost Star', '⭐', [
      'One star slipped from the night sky and landed in a garden.',
      'A child found it glowing softly under a leaf.',
      'They carried it up the hill where the sky felt closer.',
      'The star floated home, and the garden kept a little shine.',
    ]),
    _Story('drum', 'The Quiet Drum', '🥁', [
      'A drum in the playroom wanted to make a gentle sound.',
      'Tap tap, not too loud, so the baby could still sleep.',
      'Friends clapped along in a tiny parade around the rug.',
      'The drum smiled. Soft music can still be a party.',
    ]),
  ];

  int _storyIndex = 0;
  int _page = 0;
  final Set<String> _finished = {};

  _Story get _story => _stories[_storyIndex];

  Future<void> _read() async {
    await Speaker.say(_story.pages[_page]);
  }

  void _next() {
    if (_page < _story.pages.length - 1) {
      setState(() => _page++);
      _read();
      return;
    }
    if (_finished.add(_story.id)) {
      AppStore.instance.markLearned('stories', _story.id);
      AppStore.instance.recordActivity(
        subject: 'Stories',
        title: _story.title,
        score: 100,
        stars: 3,
      );
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_story.title} is finished'),
        content: const Text('⭐⭐⭐\nYou heard the whole story.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stay')),
          if (_storyIndex < _stories.length - 1)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _storyIndex++;
                  _page = 0;
                });
              },
              child: const Text('Next story'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(title: const Text('Stories')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                for (var i = 0; i < _stories.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _storyIndex = i;
                          _page = 0;
                        }),
                        child: Text(_stories[i].emoji, textAlign: TextAlign.center, style: TextStyle(fontSize: i == _storyIndex ? 28 : 20)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_story.emoji, style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 12),
                    Text(_story.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const SizedBox(height: 16),
                    Text(_story.pages[_page], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.4)),
                    const SizedBox(height: 8),
                    Text('Page ${_page + 1} of ${_story.pages.length}', style: const TextStyle(color: Colors.black45)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton(onPressed: _read, child: const Text('Read aloud')),
                const Spacer(),
                FilledButton(
                  onPressed: _next,
                  child: Text(_page == _story.pages.length - 1 ? 'The end' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

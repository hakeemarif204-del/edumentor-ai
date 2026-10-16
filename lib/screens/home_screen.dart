import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../data/session_host.dart';
import '../theme/kid_theme.dart';
import 'alphabets_screen.dart';
import 'colours_screen.dart';
import 'colouring_hub_screen.dart';
import 'games_hub_screen.dart';
import 'matching_screen.dart';
import 'mentor_screen.dart';
import 'numbers_hub_screen.dart';
import 'parent_pin_screen.dart';
import 'parent_auth_screen.dart';
import 'parents_zone_screen.dart';
import 'rhymes_screen.dart';
import 'science_screen.dart';
import 'shapes_screen.dart';
import 'stories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openParentZone(BuildContext context) {
    final store = AppStore.instance;
    final signedIn = FirebaseAuth.instance.currentUser != null;
    final Widget page;
    if (!signedIn) {
      page = const ParentAuthScreen();
    } else if (store.pinEnabled) {
      page = const ParentPinScreen();
    } else {
      page = const ParentsZoneScreen();
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    const subjects = [
      _Subject('Alphabets', 'Letters to say', '🔤', KidColors.plum),
      _Subject('Numbers', 'Count and add', '🔢', KidColors.sun),
      _Subject('Colouring', 'Pictures to paint', '🎨', KidColors.berry),
      _Subject('Shapes', 'Round and pointy', '🔺', KidColors.sky),
      _Subject('Colours', 'Red, blue, yellow', '🖌️', KidColors.coral),
      _Subject('Rhymes', 'Clap and sing', '🎵', KidColors.plum),
      _Subject('Matching', 'Find the pair', '🧩', KidColors.sun),
      _Subject('Science Fun', 'Little facts', '🧪', KidColors.leaf),
      _Subject('Stories', 'Listen to the end', '📖', KidColors.berry),
      _Subject('Fun Games', 'Play and count', '🐠', KidColors.sky),
    ];

    return Scaffold(
      backgroundColor: KidColors.cream,
      drawer: Drawer(
        backgroundColor: KidColors.cream,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 10),
                    Text(
                      'Edu Mentor AI',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: KidColors.ink),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: KidColors.plum,
                  child: Icon(Icons.shield, color: Colors.white, size: 18),
                ),
                title: const Text('Parent Zone', style: TextStyle(fontWeight: FontWeight.w700, color: KidColors.ink)),
                subtitle: const Text('Progress, goals, and settings'),
                onTap: () {
                  Navigator.pop(context);
                  _openParentZone(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AppStore.instance,
          builder: (context, _) {
            final child = AppStore.instance.activeChild;
            final showReminder = AppStore.instance.dailyReminder &&
                !AppStore.instance.activities.any((item) => item.childId == child.id && _isToday(item.at));
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: KidColors.ink),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Text('🤖', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Edu Mentor AI',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: KidColors.ink),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hello, ${child.name} ${child.avatarEmoji}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: KidColors.ink)),
                        const SizedBox(height: 4),
                        Text(
                          showReminder ? 'A tiny lesson today keeps your streak going.' : 'Let us learn one small thing together.',
                          style: const TextStyle(color: KidColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subjects.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return KidTile(
                        title: subject.title,
                        subtitle: subject.subtitle,
                        emoji: subject.emoji,
                        accent: subject.accent,
                        onTap: () => _open(context, subject.title),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => openLearning(context, page: const MentorScreen()),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xFFEDE7FF),
                              child: Icon(Icons.mic, color: KidColors.plum),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Talk to your teacher', style: TextStyle(fontWeight: FontWeight.w800, color: KidColors.ink)),
                                  Text('Ask about a letter, a number, or a colour.', style: TextStyle(fontSize: 12, color: KidColors.muted)),
                                ],
                              ),
                            ),
                            Text('🤖', style: TextStyle(fontSize: 28)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _open(BuildContext context, String title) {
    switch (title) {
      case 'Alphabets':
        openLearning(context, page: const AlphabetsScreen());
      case 'Numbers':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NumbersHubScreen()));
      case 'Colouring':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ColouringHubScreen()));
      case 'Shapes':
        openLearning(context, page: const ShapesScreen());
      case 'Colours':
        openLearning(context, page: const ColoursScreen());
      case 'Rhymes':
        openLearning(context, page: const RhymesScreen());
      case 'Matching':
        openLearning(context, page: const MatchingScreen());
      case 'Science Fun':
        openLearning(context, page: const ScienceScreen());
      case 'Stories':
        openLearning(context, page: const StoriesScreen());
      case 'Fun Games':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const GamesHubScreen()));
    }
  }

  bool _isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year && time.month == now.month && time.day == now.day;
  }
}

class _Subject {
  final String title;
  final String subtitle;
  final String emoji;
  final Color accent;
  const _Subject(this.title, this.subtitle, this.emoji, this.accent);
}

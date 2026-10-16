import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/speaker.dart';

class _Rhyme {
  final String id;
  final String title;
  final String text;
  const _Rhyme(this.id, this.title, this.text);
}

class RhymesScreen extends StatefulWidget {
  const RhymesScreen({super.key});

  @override
  State<RhymesScreen> createState() => _RhymesScreenState();
}

class _RhymesScreenState extends State<RhymesScreen> {
  static const List<_Rhyme> _rhymes = [
    _Rhyme('sun', 'Sunny Day', 'Sun comes up, the sky is blue.\nLittle birds have work to do.\nHop and flap and sing along.\nMorning starts with a happy song.'),
    _Rhyme('rain', 'Rain Boots', 'Pitter patter on the pane.\nOut we go into the rain.\nBoots go splash along the street.\nRain makes puddles for our feet.'),
    _Rhyme('cat', 'Little Cat', 'Little cat with quiet paws,\nwashes whiskers, licks her claws.\nCurls up small and shuts her eyes.\nDreams of fish and butterflies.'),
    _Rhyme('star', 'Night Star', 'One bright star above my bed,\nwinks a hello, soft and red.\nI wave back and close my eyes.\nStar keeps watch up in the skies.'),
    _Rhyme('bus', 'Yellow Bus', 'Yellow bus goes down the road,\ncarrying friends and books and load.\nStop and wave and climb inside.\nOff we roll, a bumpy ride.'),
    _Rhyme('apple', 'Apple Tree', 'Apple tree with branches wide,\nhides red apples down inside.\nPick one slowly, take a bite.\nCrunchy, juicy, sweet and bright.'),
    _Rhyme('fish', 'Tiny Fish', 'Tiny fish goes swish swish swish.\nRound the rocks to find a dish.\nBubbles rise and tickle toes.\nOff he darts where seaweed grows.'),
    _Rhyme('moon', 'Moon Friend', 'Moon is round and moon is bright.\nMoon stays up the whole long night.\nIf I whisper, moon can hear.\nSee you, moon. Sleep is near.'),
    _Rhyme('train', 'Little Train', 'Little train goes click and clack.\nDown the track and then right back.\nWindows flash with trees and sky.\nWe all wave as it rolls by.'),
    _Rhyme('bee', 'Busy Bee', 'Busy bee from flower to flower,\nworks so hard for one sweet hour.\nBuzz buzz buzz, then home to rest.\nHoney made, the bee did best.'),
  ];

  final Set<String> _heard = {};
  String? _openId;
  bool _saved = false;

  @override
  void dispose() {
    if (!_saved && _heard.isNotEmpty) {
      _saved = true;
      final score = ((_heard.length / _rhymes.length) * 100).round();
      AppStore.instance.recordActivity(
        subject: 'Rhymes',
        title: 'Rhyme time',
        score: score,
        stars: _heard.length >= 3 ? 2 : 1,
      );
    }
    super.dispose();
  }

  Future<void> _play(_Rhyme rhyme) async {
    setState(() => _openId = rhyme.id);
    _heard.add(rhyme.id);
    AppStore.instance.markLearned('rhymes', rhyme.id);
    await Speaker.say('${rhyme.title}. ${rhyme.text.replaceAll('\n', ' ')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EE),
      appBar: AppBar(title: const Text('Rhymes')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _rhymes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final rhyme = _rhymes[index];
          final open = _openId == rhyme.id;
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _play(rhyme),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🎵', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rhyme.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        if (_heard.contains(rhyme.id)) const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      ],
                    ),
                    if (open) ...[
                      const SizedBox(height: 8),
                      Text(rhyme.text, style: const TextStyle(height: 1.4)),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Tap to hear', style: TextStyle(color: Colors.black45, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

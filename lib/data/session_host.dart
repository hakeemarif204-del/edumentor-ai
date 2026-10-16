import 'dart:async';

import 'package:flutter/material.dart';

import 'app_store.dart';

Future<void> openLearning(BuildContext context, {required Widget page}) async {
  final store = AppStore.instance;
  final reason = store.blockReason();
  if (reason != null) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time for a rest'),
        content: Text(reason),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
    return;
  }
  await Navigator.push<void>(
    context,
    MaterialPageRoute(builder: (_) => SessionHost(warnAtStart: store.approachingLimit, child: page)),
  );
}

class SessionHost extends StatefulWidget {
  final Widget child;
  final bool warnAtStart;

  const SessionHost({super.key, required this.child, this.warnAtStart = false});

  @override
  State<SessionHost> createState() => _SessionHostState();
}

class _SessionHostState extends State<SessionHost> {
  Timer? _timer;
  late DateTime _started;
  int _creditedMinutes = 0;
  bool _breakShown = false;
  bool _ending = false;

  @override
  void initState() {
    super.initState();
    _started = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 20), (_) => _tick());
    if (widget.warnAtStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Almost at today\'s learning time.')),
        );
      });
    }
  }

  void _tick() {
    if (!mounted || _ending) return;
    final elapsed = DateTime.now().difference(_started);
    final wholeMinutes = elapsed.inMinutes;
    final due = wholeMinutes - _creditedMinutes;
    if (due > 0) {
      _creditedMinutes += due;
      AppStore.instance.addMinutes(due);
    }
    final store = AppStore.instance;
    if (store.breakReminders && wholeMinutes >= 15 && !_breakShown) {
      _breakShown = true;
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('A little break'),
          content: const Text('You have been learning for a while. Stretch, then come back when you are ready.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep going')),
          ],
        ),
      );
    }
    final reason = store.blockReason();
    if (reason != null) {
      _ending = true;
      _timer?.cancel();
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('That is enough for today'),
          content: Text(reason),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    final leftover = DateTime.now().difference(_started).inSeconds - (_creditedMinutes * 60);
    if (leftover >= 20 && _creditedMinutes == 0) {
      AppStore.instance.addMinutes(1);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'package:flutter/material.dart';
import 'home_screen.dart'; // adjust if your home screen file/class name differs

/// Animated splash screen for EduMentor AI.
/// Sequence: background -> floating elements -> logo fade+scale ->
/// robot wave+bounce -> sparkling stars -> tagline fade-in -> progress bar
/// -> navigates to HomeScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Named animation windows, mapped onto one 4.5s controller (0.0 - 1.0).
  late final Animation<double> _elementsFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _robotBounce;
  late final Animation<double> _robotWave;
  late final Animation<double> _starsSparkle;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progressValue;

  static const Duration _totalDuration = Duration(milliseconds: 4500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);

    _elementsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOutBack),
      ),
    );

    _robotBounce = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOutBack),
      ),
    );
    // A gentle back-and-forth wave once the robot has appeared.
    _robotWave = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeInOut),
      ),
    );

    _starsSparkle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
    );

    _taglineFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 0.9, curve: Curves.easeOut),
    );

    _progressValue = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();

    // TODO (optional): play the jingle here once you add the audioplayers
    // package to pubspec.yaml and drop a chime .mp3 into assets/sounds/.
    // Example:
    //   final player = AudioPlayer();
    //   player.play(AssetSource('sounds/edumentor_jingle.mp3'));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF6EE), Color(0xFFFFE8D6)],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Floating decorative stars + pencil, top corners.
                Positioned(
                  top: 60,
                  left: 30,
                  child: Opacity(
                    opacity: _elementsFade.value,
                    child: const Text('✏️', style: TextStyle(fontSize: 40)),
                  ),
                ),
                Positioned(
                  top: 90,
                  right: 30,
                  child: Opacity(
                    opacity: _elementsFade.value,
                    child: const Text('⭐', style: TextStyle(fontSize: 34)),
                  ),
                ),
                Positioned(
                  top: 340,
                  left: 20,
                  child: Opacity(
                    opacity: _elementsFade.value,
                    child: const Text('⭐', style: TextStyle(fontSize: 28)),
                  ),
                ),
                Positioned(
                  top: 340,
                  right: 20,
                  child: Opacity(
                    opacity: _elementsFade.value,
                    child: const Text('⭐', style: TextStyle(fontSize: 28)),
                  ),
                ),

                // Main centered column: logo, robot, tagline, progress.
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo: "EduMentor AI"
                      Opacity(
                        opacity: _logoFade.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                              ),
                              children: [
                                TextSpan(
                                  text: 'EduMentor ',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'AI',
                                  style: TextStyle(color: Color(0xFF3B2A5A)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Robot: bounces up into place, then gives a little wave.
                      Transform.translate(
                        offset: Offset(0, _robotBounce.value),
                        child: Transform.rotate(
                          angle: _robotWave.value,
                          child: Opacity(
                            opacity: _elementsFade.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Text('🤖', style: TextStyle(fontSize: 110)),
                                // Sparkle stars around the robot.
                                Positioned(
                                  top: 0,
                                  left: 10,
                                  child: Opacity(
                                    opacity: _starsSparkle.value,
                                    child: const Text('✨', style: TextStyle(fontSize: 22)),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: 0,
                                  child: Opacity(
                                    opacity: _starsSparkle.value,
                                    child: const Text('✨', style: TextStyle(fontSize: 22)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Tagline
                      Opacity(
                        opacity: _taglineFade.value,
                        child: const Text(
                          'Learn, Play & Grow!',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF4A4A68),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // "Getting ready..." + progress bar
                      Opacity(
                        opacity: _taglineFade.value,
                        child: Column(
                          children: [
                            const Text(
                              'Getting ready to learn...',
                              style: TextStyle(fontSize: 14, color: Color(0xFF6A6A8A)),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 220,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: _progressValue.value,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withOpacity(0.5),
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6B4EFF)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
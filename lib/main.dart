import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/app_store.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/kid_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppStore.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu Mentor AI',
      debugShowCheckedModeBanner: false,
      theme: KidTheme.data(),
      home: const SplashScreen(),
    );
  }
}

import 'package:ex_date/firebase_options.dart';
import 'package:ex_date/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final theme = ThemeData(
  brightness: Brightness.light,
  colorScheme:
      ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 0, 111)),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: const SplashScreen(),
    );
  }
}

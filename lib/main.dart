import 'package:ex_date/firebase_options.dart';
import 'package:ex_date/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ex_date/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();//required for displaying local notifications

final ValueNotifier<bool> isLightTheme = ValueNotifier(true);
final ValueNotifier<bool> isOn = ValueNotifier(true); //global for toggling notifications

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Load dotenv before Firebase, this file contains sensitive info like api keys
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  tz.initializeTimeZones();

  //notification setup
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await setupPushNotifications();//if we want to send notifications to all the devices from server at a particular time
  await scheduleNotification(isOn.value); //notific. schedule karenge only if ON

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isLightTheme,
      builder: (context, isLight, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isLight ? Brightness.light : Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 255, 0, 111),
              brightness: isLight ? Brightness.light : Brightness.dark,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

import 'package:ex_date/screens/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  void _startSplashScreen() async{
    await Future.delayed(const Duration(seconds: 4),);

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.primary,
          child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 20, end: 40),
              duration: const Duration(seconds: 2),
              builder: (context, val, child) {
                return Text(
                  "ExDate",
                  style: TextStyle(
                    fontSize: val,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
        ),
      ),
    );
  }
}

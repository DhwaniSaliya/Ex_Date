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
    _startSplashScreen(); //call splash delay logic as soon as the widget is built
  }

  void _startSplashScreen() async{
    await Future.delayed(const Duration(seconds: 4),); //wait for 4 sec

    if (!mounted) return; //ensure that widget is still in the widget tree
    //navigate to login screen and remove splash screen from the stack
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
          // Animate text size from 20 to 40 over 2 seconds
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

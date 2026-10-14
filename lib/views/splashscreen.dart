import 'package:expenzia/views/mainshell.dart';
import 'package:expenzia/views/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openNext();
  }

  Future<void> _openNext() async {
    await Future.delayed(Duration(milliseconds: 1100));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => done ? MainShell() : OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Color(0xFF2F7E79),
      body: Center(
          child: Text('Expenzia',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  letterSpacing: -.5))));
}

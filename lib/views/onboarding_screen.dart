import 'package:expenzia/views/mainshell.dart';
import 'package:expenzia/widget/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  Future<void> _start(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (context.mounted)
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 25),
              child: Column(children: [
                const Spacer(),
                Expanded(
                    flex: 7,
                    child: Image.asset('assets/Group 1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.savings_outlined,
                            size: 150,
                            color: Color(0xFF2F7E79)))),
                const SizedBox(height: 16),
                const Text('Spend Smarter\nSave More',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF2F7E79),
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 26),
                PrimaryButton(
                    label: 'Get Started', onPressed: () => _start(context)),
              ]))));
}

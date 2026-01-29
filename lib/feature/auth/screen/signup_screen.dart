import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  static String name = '/signup';
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Sign')],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SigninScreen extends StatelessWidget {
  static String name = '/signin';
  const SigninScreen({super.key});

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

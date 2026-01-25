import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static String name = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Home')],
          ),
        ),
      ),
    );
  }
}

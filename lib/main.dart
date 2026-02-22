import 'package:flutter/material.dart';
import 'package:test_ravidu/screen/login.dart';

void main() {
runApp(GemJobApp());
}

class GemJobApp extends StatelessWidget {
  const GemJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gem Job',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:test_ravidu/screen/login.dart';
import 'package:test_ravidu/db/db_helper.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 

  await DBHelper.database(); 

  await DBHelper.insertDemoData(); 

  runApp(const GemJobApp());
}

class GemJobApp extends StatelessWidget {
  const GemJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gem Job',
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003366)),
      ),
      home: const LoginScreen(),
    );
  }
}
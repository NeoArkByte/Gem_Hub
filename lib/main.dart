import 'package:flutter/material.dart';
import 'Screen/geminventory.dart';
import 'utils/app_thems.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.emeraldTheme,
      darkTheme: AppThemes.darkTheme,
      home: inventory(),
    );
  }
}




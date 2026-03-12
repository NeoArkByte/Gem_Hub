import 'package:flutter/material.dart';
import 'package:job_market/Test/login_screen.dart';
import 'package:job_market/Screen/Job_details.dart';

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
      // --- 1. LIGHT MODE THEME ---
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light background
        primaryColor: const Color(0xFF10C971),
        fontFamily: 'Roboto',
      ),

      // --- 2. DARK MODE THEME ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827), // Dark background
        primaryColor: const Color(0xFF10C971),
        fontFamily: 'Roboto',
      ),

      // --- 3. MAGIC COMMAND EKA ---
      // Meken phone eke system eka dark nam dark theme ekath, light nam light theme ekath auto gannawa
      themeMode: ThemeMode.system,
      //home: JobDetailsScreen(),
      //home: JobMarketplaceScreen(),
      //home: AdminJobReviewScreen(),
      home: LoginScreen(),
    );
  }
}


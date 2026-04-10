import 'package:flutter/material.dart';
import 'package:job_market/Test/login_screen.dart';
import 'package:job_market/Screen/Job_market.dart';

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
  
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Light background
        primaryColor: const Color(0xFF10C971),
        fontFamily: 'Roboto',
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111827), // Dark background
        primaryColor: const Color(0xFF10C971),
        fontFamily: 'Roboto',
      ),

      themeMode: ThemeMode.system,
      //home: JobDetailsScreen(),
      home: JobMarketplaceScreen(),
      //home: AdminJobReviewScreen(),
      //home: LoginScreen(),
    );
  }
}


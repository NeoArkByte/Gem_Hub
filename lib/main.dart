import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 👈 1. Import kala
import 'package:job_market/features/marketplace/view/job_market.dart'; // Path check karanna

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 👇 2. ProviderScope eken wrap kala
  runApp(const ProviderScope(child: MyApp())); 
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemCost Jobs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF10C971),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF10C971),
      ),
      themeMode: ThemeMode.system, 
      home: const JobMarketplaceScreen(), 
    );
  }
}
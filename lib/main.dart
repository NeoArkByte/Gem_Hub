import 'package:flutter/material.dart';
import 'package:test_ravidu/screen/login.dart';
import 'package:test_ravidu/db/db_helper.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized(); // Meka aniwaryen ona
  await DBHelper.insertDemoData(); // Demo data insert karanawa
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

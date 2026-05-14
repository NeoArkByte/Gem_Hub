import 'package:flutter/material.dart';
import 'package:job_market/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ✅ IMPORT the router provider file here
// Replace 'job_market' with your actual package name if it differs
import 'package:job_market/core/router/app_router.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final dbHelper = DatabaseHelper();
  
  await dbHelper.database;

  // Cheking if the database header is encrypted or not
  await dbHelper.hexDumpHeader();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GemCost Jobs',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryGreen,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryGreen,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
    );
  }
}
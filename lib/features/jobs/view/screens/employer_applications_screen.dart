import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/features/jobs/view/screens/cv_viewer_screen.dart';

class EmployerApplicationsScreen extends ConsumerStatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  ConsumerState<EmployerApplicationsScreen> createState() =>
      _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState
    extends ConsumerState<EmployerApplicationsScreen> {
  final Color primaryGreen = const Color(0xFF10C971);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA);
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    Color cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Received Applications',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [],
      ),
    );
  }
}

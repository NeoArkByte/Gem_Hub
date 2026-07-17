import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/core/enums/user_role.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart'; // Updated import
import 'package:gemhub/shared/widgets/bottom_navigation_bar.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class MainNavigation extends ConsumerWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final user = sessionAsync.value;
    final location = GoRouterState.of(context).uri.path;

    final routes = ['/home', '/inventory', '/gems', '/jobs', '/profile'];

    int currentIndex = 0;
    if (location.startsWith('/inventory')) {
      currentIndex = 1;
    } else if (location.startsWith('/gems')) {
      currentIndex = 2;
    } else if (location.startsWith('/jobs')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      currentIndex = 4;
    } else {
      currentIndex = 0; // Default to /home
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackgroundAlt;
    final isAdmin = user?.profile?.role == UserRole.ADMIN;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: isAdmin
          ? null
          : AppBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index >= 0 && index < routes.length) {
                  context.go(routes[index]);
                }
              },
            ),
    );
  }
}

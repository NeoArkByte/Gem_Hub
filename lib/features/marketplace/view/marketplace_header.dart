import 'package:flutter/material.dart';
import 'package:job_market/features/auth/view/login_screen.dart';
import 'package:job_market/features/marketplace/view/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_market/features/jobs/view/PostNewJob/employer_applications_screen.dart';
import 'package:job_market/features/navigation/view/main_navigation.dart';

class MarketplaceHeader extends StatelessWidget {
  final bool isLoggedIn;

  const MarketplaceHeader({Key? key, required this.isLoggedIn})
    : super(key: key);

  void _logout(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log Out',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigation()),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSpacing = screenWidth < 360
        ? 4.0
        : 8.0; 

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        16,
      ), 
      child: Row(
        children: [
          CircleAvatar(
            radius:
                20, 
            backgroundImage: isLoggedIn
                ? const NetworkImage('https://i.pravatar.cc/150?img=32')
                : null,
            backgroundColor: isDark
                ? const Color(0xFF374151)
                : Colors.grey[300],
            child: !isLoggedIn
                ? const Icon(Icons.person, color: Colors.grey, size: 20)
                : null,
          ),
          const SizedBox(width: 10),

          // 👇 FIX EKA METHANA: Expanded damma, ethakota anith ewata ida deela meka shrink wenawa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoggedIn ? 'Welcome Back!' : 'Welcome, Guest',
                  style: TextStyle(
                    fontSize: screenWidth < 360
                        ? 16
                        : 18, // Podi phone walata font size ekath adu wenawa
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow
                      .ellipsis, // Text eka loku wadi nam '...' kiyala penne mekai
                ),
                Text(
                  'Find your next gem career',
                  style: TextStyle(
                    fontSize: screenWidth < 360 ? 11 : 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Spacer() eka methanata onna na dan Expanded dapu nisa.

          // Icons tika me peththata gaththa
          Row(
            mainAxisSize: MainAxisSize
                .min, // Me Row eka ganna ona aduma ida witharak gannawa
            children: [
              if (isLoggedIn) ...[
                _iconButton(
                  Icons.inbox_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const EmployerApplicationsScreen(),
                      ),
                    );
                  },
                  isDark,
                  iconColor: const Color(0xFF3B82F6),
                ),
                SizedBox(width: iconSpacing),
                _iconButton(Icons.notifications_none, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                }, isDark),
              ],

              SizedBox(width: iconSpacing),

              _iconButton(
                isLoggedIn ? Icons.logout : Icons.login,
                () {
                  if (isLoggedIn) {
                    _logout(context);
                  } else {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                isDark,
                iconColor: isLoggedIn
                    ? const Color(0xFFEF4444).withOpacity(0.9)
                    : const Color(0xFF10C971),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    Color? iconColor,
  }) {
    // Icons wala wate thiyena container eka poddak podi kala
    return Container(
      width: 36, // Specific size ekak dunna
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero, // Padding eka zero kala
        icon: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white : Colors.grey[800]),
          size: 22,
        ), // Icon size eka 22 -> 18 kala
        onPressed: onTap,
        splashRadius: 20,
      ),
    );
  }
}

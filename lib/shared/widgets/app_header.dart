import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_market/features/auth/view/login_screen.dart';
import 'package:job_market/features/marketplace/view/notification_screen.dart';
import 'package:job_market/features/jobs/view/PostNewJob/employer_applications_screen.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  bool _isLoggedIn = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isLoggedIn = prefs.getString('logged_in_user_id') != null;
        _userName = prefs.getString('logged_in_user_name') ?? '';
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
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
              if (ctx.mounted) {
                Navigator.pop(ctx);
                // Refresh the header state
                _loadAuthState();
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
    double iconSpacing = screenWidth < 360 ? 4.0 : 8.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: _isLoggedIn
                ? const NetworkImage('https://i.pravatar.cc/150?img=32')
                : null,
            backgroundColor:
                isDark ? const Color(0xFF374151) : Colors.grey[300],
            child: !_isLoggedIn
                ? const Icon(Icons.person, color: Colors.grey, size: 20)
                : null,
          ),
          const SizedBox(width: 10),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoggedIn
                      ? 'Welcome Back${_userName.isNotEmpty ? ', $_userName' : ''}!'
                      : 'Welcome, Guest',
                  style: TextStyle(
                    fontSize: screenWidth < 360 ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

          // Action icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoggedIn) ...[
                _iconButton(
                  Icons.inbox_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployerApplicationsScreen(),
                      ),
                    );
                  },
                  isDark,
                  iconColor: const Color(0xFF3B82F6),
                ),
                SizedBox(width: iconSpacing),
                _iconButton(
                  Icons.notifications_none,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                  isDark,
                ),
                SizedBox(width: iconSpacing),
              ],
              _iconButton(
                _isLoggedIn ? Icons.logout : Icons.login,
                () {
                  if (_isLoggedIn) {
                    _showLogoutDialog(context);
                  } else {
                    // Navigate to login and refresh header state on return
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ))
                        .then((_) => _loadAuthState());
                  }
                },
                isDark,
                iconColor: _isLoggedIn
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
    return Container(
      width: 36,
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
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white : Colors.grey[800]),
          size: 20,
        ),
        onPressed: onTap,
        splashRadius: 18,
      ),
    );
  }
}

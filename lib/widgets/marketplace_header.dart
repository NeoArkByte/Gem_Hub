import 'package:flutter/material.dart';
import 'package:job_market/Test/login_screen.dart';
import 'package:job_market/Screen/PostNewJob/employer_applications_screen.dart'; 
import 'package:job_market/widgets/notification_screen.dart';


class MarketplaceHeader extends StatelessWidget {
  const MarketplaceHeader({Key? key}) : super(key: key);

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
            onPressed: () => Navigator.pushAndRemoveUntil(
              ctx,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GemCost Jobs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              Text(
                'Find your next gem career',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          
          // 👇 ALUTH INBOX BUTTON EKA (Applications balanna)
          _iconButton(
            Icons.inbox_outlined, 
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmployerApplicationsScreen()),
              );
            }, 
            isDark,
            iconColor: const Color(0xFF10C971), // Lassanata Green color eka dunna
          ),
          const SizedBox(width: 8),

          // Notification Button
         // 👇 Notification Button eka link kala
          _iconButton(
            Icons.notifications_none, 
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            }, 
            isDark
          ),
          const SizedBox(width: 8),

          // Logout Button
          _iconButton(
            Icons.logout,
            () => _logout(context),
            isDark,
            iconColor: const Color(0xFFEF4444).withOpacity(0.9),
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
        icon: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white : Colors.grey[800]),
          size: 22,
        ),
        onPressed: onTap,
        splashRadius: 24,
      ),
    );
  }
}
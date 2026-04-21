import 'package:flutter/material.dart';
import 'package:job_market/features/auth/view/login_screen.dart';
import 'package:job_market/features/marketplace/view/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_market/features/jobs/view/PostNewJob/employer_applications_screen.dart'; // 👈 Path eka hariyata danna

class MarketplaceHeader extends StatelessWidget {
  // 👇 ALUTH KALLA: User log welada nadda kiyala meken check karanawa
  final bool isLoggedIn; 
  
  const MarketplaceHeader({Key? key, required this.isLoggedIn}) : super(key: key);

  void _logout(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        content: Text('Are you sure you want to log out?', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              // 👇 Logout weddi phone eke mathaka thiyena data ain karanawa
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); 
              
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  ctx,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            // Log wela nam profile pic eka, nattam dummy icon ekak
            backgroundImage: isLoggedIn ? const NetworkImage('https://i.pravatar.cc/150?img=32') : null,
            backgroundColor: isDark ? const Color(0xFF374151) : Colors.grey[300],
            child: !isLoggedIn ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // 👇 Log wela nam nama pennanawa, nattam 'Guest' kiyanawa
                isLoggedIn ? 'Welcome Back!' : 'Welcome, Guest',
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
          
          // 👇 Log wela nam INBOX eka pennanawa
          if (isLoggedIn) ...[
            _iconButton(
              Icons.inbox_outlined, 
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployerApplicationsScreen()));
              }, 
              isDark,
              iconColor: const Color(0xFF3B82F6), // Podi Blue color ekak dunna wenas wenna
            ),
            const SizedBox(width: 8),
            _iconButton(
              Icons.notifications_none, 
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
              }, 
              isDark,
            ),
          ],
            
          const SizedBox(width: 8),

          // 👇 Log wela nam LOGOUT icon eka, Nattam LOGIN icon eka
          _iconButton(
            isLoggedIn ? Icons.logout : Icons.login,
            () {
              if (isLoggedIn) {
                _logout(context);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
            isDark,
            iconColor: isLoggedIn ? const Color(0xFFEF4444).withOpacity(0.9) : const Color(0xFF10C971),
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, bool isDark, {Color? iconColor}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor ?? (isDark ? Colors.white : Colors.grey[800]), size: 22),
        onPressed: onTap,
        splashRadius: 24,
      ),
    );
  }

  
}
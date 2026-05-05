import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/auth/user_model.dart';
import 'package:job_market/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:job_market/features/auth/viewmodels/auth_viewmodel.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Exact colors from your reference
    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: null,
    
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          if (user == null) return const Center(child: Text("No Profile Found"));
          return _buildBody(context, ref, user, textColor, cardColor, isDark);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, UserModel user, Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildHeader(user, textColor),
          const SizedBox(height: 25),
          _buildStats(user, textColor),
          const SizedBox(height: 30),
          
          _buildSectionTitle("ACCOUNT DETAILS"),
          _buildMenuCard(cardColor, [
            _buildMenuTile(Icons.person, Colors.blue.shade50, Colors.blue, "Edit Personal Profile", textColor),
            _buildMenuTile(Icons.business_center, Colors.indigo.shade50, Colors.indigo, "Business Documents (KYC)", textColor),
            _buildMenuTile(Icons.archive, Colors.blue.shade50, Colors.blue.shade700, "Inventory Preferences", textColor),
          ]),

          const SizedBox(height: 25),
          _buildSectionTitle("NOTIFICATION SETTINGS"),
          _buildMenuCard(cardColor, [
            _buildMenuTile(Icons.notifications, Colors.orange.shade50, Colors.orange, "Push Notifications", textColor, trailing: Switch(value: true, onChanged: (v){}, activeColor: Colors.blue)),
            _buildMenuTile(Icons.trending_down, Colors.green.shade50, Colors.green, "Marketplace Alerts", textColor),
            _buildMenuTile(Icons.work, Colors.purple.shade50, Colors.purple, "Job Board Alerts", textColor),
          ]),

          const SizedBox(height: 25),
          _buildSectionTitle("SUPPORT & LEGAL"),
          _buildMenuCard(cardColor, [
            _buildMenuTile(Icons.help, Colors.blueGrey.shade50, Colors.blueGrey, "Help Center", textColor),
            _buildMenuTile(Icons.verified_user, Colors.blueGrey.shade50, Colors.blueGrey, "Terms & Privacy", textColor),
          ]),

          const SizedBox(height: 30),
          _buildSignOutButton(ref, context),
          
          const SizedBox(height: 20),
          Text("GemVault Pro v2.4.1", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          Text("Securing the global gemstone trade", style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontStyle: FontStyle.italic)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(UserModel user, Color textColor) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.yellow.shade600, width: 2)),
              child: const CircleAvatar(radius: 55, backgroundImage: NetworkImage('https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zToAs08CTtaS97LYWls3XY9PjKlztzWp.jpg')),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.verified, color: Colors.blue, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(user.name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
        Text(user.title ?? "SENIOR GEMOLOGIST", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blue.shade100)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.stars, color: Colors.blue, size: 16),
              SizedBox(width: 6),
              Text("Verified Seller", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text("Member since ${user.memberSince ?? 'August 2021'}", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildStats(UserModel user, Color textColor) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem(user.itemsCount?.toString() ?? "0", "ITEMS", textColor),
          VerticalDivider(color: Colors.grey.shade300, thickness: 1, indent: 10, endIndent: 10),
          _statItem(user.rating?.toString() ?? "0.0", "RATING", textColor),
          VerticalDivider(color: Colors.grey.shade300, thickness: 1, indent: 10, endIndent: 10),
          _statItem(user.salesCount ?? "0", "SALES", textColor),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 10),
        child: Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildMenuCard(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
      ]),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(IconData icon, Color iconBg, Color iconColor, String title, Color textColor, {Widget? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
    );
  }

  Widget _buildSignOutButton(WidgetRef ref, BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () => _showLogoutConfirmation(context, ref),
      icon: const Icon(Icons.logout, color: Colors.red),
      label: const Text(
        "Sign Out",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: const BorderSide(color: Color(0xFFFFEBEE)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
  );
}

void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out of your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              // 1. Clear session data
              await ref.read(authViewModelProvider.notifier).logout();
              
              if (context.mounted) {
                // 2. Close dialog
                Navigator.pop(context); 
                
                // 3. Navigate to login and remove all previous screens from stack
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
}
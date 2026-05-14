import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/auth/auth_state.dart';
import 'package:job_market/features/auth/provider/session_provider.dart';
import 'package:job_market/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:job_market/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:job_market/core/constants/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? AppColors.darkBackgroundAlt
        : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color cardColor = isDark ? AppColors.textDarkAlt : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: sessionState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (authData) {
          if (authData == null) {
            return const Center(child: Text("No active session found"));
          }

          return _buildBody(context, ref, authData, textColor, cardColor);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AuthenticatedUser authData,
    Color textColor,
    Color cardColor,
  ) {
    final profile = authData.profile;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(authData, textColor),
            const SizedBox(height: 24),
            _buildItemsStat(ref, textColor),
            const SizedBox(height: 24),
            _buildSectionTitle("Account Details"),
            _buildMenuCard(cardColor, [
              _buildMenuTile(
                Icons.person,
                Colors.blue.shade50,
                Colors.blue,
                "Edit Personal Profile",
                textColor,
              ),
              _buildMenuTile(
                Icons.inventory_2,
                Colors.teal.shade50,
                Colors.teal,
                "Inventory Preferences",
                textColor,
              ),
            ]),
            const SizedBox(height: 18),
            _buildSectionTitle("Notification Settings"),
            _buildMenuCard(cardColor, [
              _buildMenuTile(
                Icons.notifications_active,
                Colors.green.shade50,
                Colors.green,
                "Marketplace Alerts",
                textColor,
              ),
              _buildMenuTile(
                Icons.work_outline,
                Colors.purple.shade50,
                Colors.purple,
                "Job Board Alerts",
                textColor,
              ),
            ]),
            const SizedBox(height: 18),
            _buildSectionTitle("Support & Legal"),
            _buildMenuCard(cardColor, [
              _buildMenuTile(
                Icons.help_outline,
                Colors.grey.shade100,
                Colors.black87,
                "Help Center",
                textColor,
              ),
              _buildMenuTile(
                Icons.shield_outlined,
                Colors.grey.shade100,
                Colors.black87,
                "Terms & Privacy",
                textColor,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSignOutButton(ref, context),
            const SizedBox(height: 18),
            Center(
              child: Text(
                "GemVault Pro v2.4.1",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthenticatedUser authData, Color textColor) {
    final profile = authData.profile;
    final supabaseUser = authData.supabaseUser;

    return SizedBox(
      width: double.infinity, 
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.center, 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Profile Picture
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.yellow.shade600, width: 2),
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundImage: NetworkImage(
                profile?.avatarUrl ??
                    'https://i.pravatar.cc/150?u=${supabaseUser?.id}',
              ),
            ),
          ),
          const SizedBox(height: 15),

          // 2. Username
          Text(
            profile?.username ??
                supabaseUser?.email?.split('@')[0] ??
                "Gem Owner",
            textAlign:
                TextAlign.center, 
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),

          // 3. Description
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
            ), 
            child: Text(
              profile?.description ?? "No profile description",
              textAlign: TextAlign.center, 
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 4. Member Since
          Text(
            "Member since ${_formatDate(profile?.createdAt)}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'unknown';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[parsed.month - 1];
    return '$month ${parsed.day}, ${parsed.year}';
  }

  Widget _buildItemsStat(WidgetRef ref, Color textColor) {
    final inventoryAsync = ref.watch(inventoryViewModelProvider);

    return inventoryAsync.when(
      data: (gems) {
        // Logic: isSold 
        final availableItems = gems.where((g) => g.isSold == false).length;

       
        final salesCount = gems.where((g) => g.isSold == true).length;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: Theme.of(ref.context).brightness == Brightness.dark
                ? AppColors.textDarkAlt
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicHeight(
            
            child: Row(
              children: [
                _statItem(availableItems.toString(), "ITEMS", textColor),
                VerticalDivider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  width: 1,
                ),
                _statItem(salesCount.toString(), "SALES", textColor),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => _statItem("0", "ITEMS", textColor),
    );
  }

  Widget _statItem(String value, String label, Color textColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              letterSpacing: 1.1,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 10),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(Color cardColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuTile(
    IconData icon,
    Color iconBg,
    Color iconColor,
    String title,
    Color textColor, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing:
          trailing ??
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
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
          side: const BorderSide(color: AppColors.redSoft),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Sign Out"),
          content: const Text(
            "Are you sure you want to sign out of your account?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(authViewModelProvider.notifier).logout();

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Logout failed: $e")),
                    );
                  }
                }
              },
              child: const Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

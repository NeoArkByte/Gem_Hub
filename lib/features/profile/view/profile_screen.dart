import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/data/models/auth/auth_state.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/profile/view/edit_profile_screen.dart';
import 'package:gemhub/shared/widgets/custom_confirm_dialog.dart';
import 'package:gemhub/shared/widgets/custom_toast.dart'; // Imported CustomToast
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color bgColor = isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: sessionState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: textColor))),
        data: (authData) {
          if (authData == null) {
            return Center(child: Text("No active session found", style: TextStyle(color: textColor)));
          }
          return _buildBody(context, ref, authData, textColor, cardColor, isDark);
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
    bool isDark,
  ) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(authData, textColor, isDark),
            const SizedBox(height: 28),
            _buildItemsStat(ref, textColor, cardColor, isDark),
            const SizedBox(height: 28),
            
            _buildSectionTitle("ACCOUNT DETAILS"),
            _buildMenuCard(cardColor, isDark, [
              _buildMenuTile(
                icon: Icons.person_outline_rounded,
                iconBg: AppColors.primaryBlue.withOpacity(0.12),
                iconColor: AppColors.primaryBlue,
                title: "Edit Personal Profile",
                textColor: textColor,
                onTap: () async {
                  if (authData.profile == null) return;
                  
                  final dataChanged = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(profile: authData.profile!),
                    ),
                  );

                  if (dataChanged == true && context.mounted) {
                    ref.invalidate(sessionProvider);
                    CustomToast.showSuccess(context, "Profile settings updated successfully!");
                  }
                },
              ),
              _buildMenuTile(
                icon: Icons.cloud_sync_outlined,
                iconBg: AppColors.accentPurple.withOpacity(0.12),
                iconColor: AppColors.accentPurple,
                title: "Cloud Backup & Sync",
                textColor: textColor,
                onTap: () => context.push('/profile/backup'),
              ),
              _buildMenuTile(
                icon: Icons.tune_rounded,
                iconBg: AppColors.gold.withOpacity(0.12),
                iconColor: AppColors.gold,
                title: "Inventory Preferences",
                textColor: textColor,
              ),
            ]),
            const SizedBox(height: 24),
            
            _buildSectionTitle("MARKETPLACE WORKSPACE"),
            _buildMenuCard(cardColor, isDark, [
              _buildMenuTile(
                icon: Icons.business_center_outlined,
                iconBg: AppColors.primaryBlue.withOpacity(0.12),
                iconColor: AppColors.primaryBlue,
                title: "My Job Posts",
                textColor: textColor,
                onTap: () => context.push('/my-jobs'),
              ),
              _buildMenuTile(
                icon: Icons.layers_outlined,
                iconBg: AppColors.primaryGreen.withOpacity(0.12),
                iconColor: AppColors.primaryGreen,
                title: "Gem Marketplace Inventory",
                textColor: textColor,
                onTap: () => context.push('/gems/inventory'),
              ),
            ]),
            const SizedBox(height: 24),
            
            _buildSectionTitle("SUPPORT & LEGAL"),
            _buildMenuCard(cardColor, isDark, [
              _buildMenuTile(
                icon: Icons.help_outline_rounded,
                iconBg: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                iconColor: isDark ? Colors.white70 : Colors.black87,
                title: "Help Center",
                textColor: textColor,
                onTap: () => context.push('/help-center'),
              ),
              _buildMenuTile(
                icon: Icons.shield_outlined,
                iconBg: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                iconColor: isDark ? Colors.white70 : Colors.black87,
                title: "Terms & Privacy",
                textColor: textColor,
                onTap: () => context.push('/terms-privacy'),
              ),
            ]),
            const SizedBox(height: 32),
            
            _buildSignOutButton(ref, context),
            const SizedBox(height: 24),
            
            Center(
              child: Text(
                "GemVault Pro v2.4.1",
                style: const TextStyle(color: AppColors.greyTextLight, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AuthenticatedUser authData, Color textColor, bool isDark) {
    final profile = authData.profile;
    final supabaseUser = authData.supabaseUser;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBackgroundGrey,
              backgroundImage: profile?.avatarUrl != null
                  ? NetworkImage(profile!.avatarUrl!) as ImageProvider
                  : const AssetImage('assets/images/default_avatar.png'),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile?.username ?? supabaseUser?.email?.split('@')[0] ?? "Gem Owner",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              profile?.description ?? "No profile description template initialized.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.greyText, fontSize: 13, fontWeight: FontWeight.normal, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Member since ${_formatDate(profile?.createdAt)}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.greyTextLight, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsStat(WidgetRef ref, Color textColor, Color cardColor, bool isDark) {
    final inventoryAsync = ref.watch(inventoryViewModelProvider);

    return inventoryAsync.when(
      data: (gems) {
        final availableItems = gems.where((g) => g.isSold == false).length;
        final salesCount = gems.where((g) => g.isSold == true).length;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _statItem(availableItems.toString(), "ITEMS AVAILABLE", textColor),
                VerticalDivider(color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder, thickness: 1, width: 1),
                _statItem(salesCount.toString(), "TOTAL SALES", textColor),
              ],
            ),
          ),
        );
      },
      loading: () => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: const CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryGreen),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder),
        ),
        child: Row(children: [_statItem("0", "ITEMS AVAILABLE", textColor), _statItem("0", "TOTAL SALES", textColor)]),
      ),
    );
  }

  Widget _statItem(String value, String label, Color textColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.greyTextLight, letterSpacing: 0.6, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.greyTextLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildMenuCard(Color cardColor, bool isDark, List<Widget> originalChildren) {
    List<Widget> splitChildren = [];
    final dividerColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

    for (var i = 0; i < originalChildren.length; i++) {
      splitChildren.add(originalChildren[i]);
      if (i < originalChildren.length - 1) {
        splitChildren.add(Divider(height: 1, color: dividerColor, indent: 54));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
          width: 1.0,
        ),
      ),
      child: Column(children: splitChildren),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.greyTextLight),
    );
  }

  Widget _buildSignOutButton(WidgetRef ref, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, ref),
        icon: const Icon(Icons.logout_rounded, color: AppColors.dangerRed, size: 18),
        label: const Text(
          "Sign Out Account",
          style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.1),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.redSoft, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'unknown';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(isDark ? 0.6 : 0.4),
      builder: (BuildContext context) {
        return const CustomConfirmDialog(
          title: "Sign Out",
          content: "Are you sure you want to sign out of your account?",
          confirmLabel: "Sign Out",
          confirmColor: AppColors.dangerRed,
          icon: Icons.logout_rounded,
        );
      },
    );

    if (confirmLogout != true || !context.mounted) return;

    try {
      await ref.read(authViewModelProvider.notifier).logout();
      if (!context.mounted) return;
      context.go('/login');
    } catch (e) {
      if (!context.mounted) return;
      // Replaced old generic SnackBar layout with your CustomToast layout builder
      CustomToast.showError(context, "Logout failed: $e");
    }
  }
}
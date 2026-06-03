import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/backup/backup_state.dart';
import 'package:gemhub/features/profile/viewmodel/backup_viewmodel.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color subtitleColor = isDark ? AppColors.greyTextLight : AppColors.greyText;
    final Color dividerColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

    // Direct system notification side-effect handling using SnackBar popups
    ref.listen(backupViewModelProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(backupViewModelProvider.notifier).clearNotifications();
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(backupViewModelProvider.notifier).clearNotifications();
      }
    });

    final uiState = ref.watch(backupViewModelProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Backup & Sync",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor, size: 20),
            onPressed: () => ref.read(backupViewModelProvider.notifier).refreshAllSnapshots(),
          )
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: uiState.isLoading
              ? _buildLoadingState(uiState.statusMessage, textColor)
              : _buildMainLayout(cardColor, textColor, subtitleColor, dividerColor, uiState, ref),
        ),
      ),
    );
  }

  Widget _buildLoadingState(String statusMessage, Color textColor) {
    return Center(
      key: const ValueKey("loading"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(strokeWidth: 3, color: AppColors.primaryBlue),
          const SizedBox(height: 24),
          Text(statusMessage, style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontSize: 15)),
          const SizedBox(height: 6),
          Text("Please do not close or leave the app", style: TextStyle(color: AppColors.greyTextMutedLight, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMainLayout(
    Color cardColor,
    Color textColor,
    Color subtitleColor,
    Color dividerColor,
    BackupState uiState,
    WidgetRef ref,
  ) {
    return ListView(
      key: const ValueKey("content"),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      children: [
        // Top Banner Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppColors.blueSoft, shape: BoxShape.circle),
                child: const Icon(Icons.cloud_done_outlined, size: 28, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Local Sandbox Storage", style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text("Status: Isolated Testing Mode Active", style: TextStyle(color: AppColors.greyTextLight, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _buildSectionHeader("AVAILABLE OPERATIONS"),
        Container(
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24)),
          child: ListTile(
            onTap: () => ref.read(backupViewModelProvider.notifier).backupAndSyncAll(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.all(Radius.circular(10))),
              child: const Icon(Icons.add_to_photos_rounded, color: AppColors.primaryBlue, size: 22),
            ),
            title: Text("Generate Backup Point", style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 15)),
            subtitle: Text("Compile current running database into a new ZIP snapshot", style: TextStyle(color: subtitleColor, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.greyTextLight),
          ),
        ),

        // Local Storage Section Render Loop
        if (uiState.localSnapshots.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader("AVAILABLE RESTORE POINTS"),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uiState.localSnapshots.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor),
              itemBuilder: (context, index) {
                final snapshot = uiState.localSnapshots[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.accentOrange.withOpacity(0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.history_toggle_off_rounded, color: AppColors.accentOrange, size: 18),
                  ),
                  title: Text(
                    snapshot.name,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "${snapshot.formattedSize} • Local Cache File",
                    style: const TextStyle(color: AppColors.greyTextLight, fontSize: 11),
                  ),
                  trailing: TextButton(
                    onPressed: () => ref.read(backupViewModelProvider.notifier).restoreFromSnapshot(snapshot),
                    child: const Text("Restore", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 10),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.greyTextLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
        ),
      ),
    );
  }
}
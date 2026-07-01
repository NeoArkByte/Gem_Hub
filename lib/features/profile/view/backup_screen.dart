import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/backup/backup_snapshot.dart';
import 'package:gemhub/data/models/backup/backup_state.dart';
import 'package:gemhub/features/profile/viewmodel/backup_viewmodel.dart';
import 'package:gemhub/shared/widgets/custom_confirm_dialog.dart';
import 'package:gemhub/shared/widgets/custom_toast.dart';

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  Future<void> _confirmDeletion(
      BuildContext context, WidgetRef ref, BackupSnapshot snapshot) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomConfirmDialog(
          title: "Delete Backup Point?",
          content:
              "Are you sure you want to permanently delete '${snapshot.name}'? This operation cannot be undone.",
          confirmLabel: "Delete",
          cancelLabel: "Cancel",
          confirmColor: AppColors.dangerRed,
          icon: Icons.delete_forever_rounded,
        );
      },
    );

    if (shouldDelete == true) {
      ref.read(backupViewModelProvider.notifier).deleteSnapshot(snapshot);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor =
        isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;
    final Color dividerColor =
        isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

    ref.listen(backupViewModelProvider, (previous, next) {
      if (next.successMessage != null) {
        CustomToast.showSuccess(context, next.successMessage!);
        ref.read(backupViewModelProvider.notifier).clearNotifications();
      } else if (next.errorMessage != null) {
        CustomToast.showError(context, next.errorMessage!);
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
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textColor, size: 20),
            onPressed: () => ref
                .read(backupViewModelProvider.notifier)
                .refreshAllSnapshots(),
          )
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: uiState.isLoading
              ? _buildLoadingState(uiState.statusMessage, textColor)
              : _buildMainLayout(cardColor, textColor, subtitleColor,
                  dividerColor, uiState, ref, context, isDark),
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
          const CircularProgressIndicator(
              strokeWidth: 3, color: AppColors.primaryBlue),
          const SizedBox(height: 24),
          Text(statusMessage,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: textColor, fontSize: 15)),
          const SizedBox(height: 6),
          const Text("Please do not close or leave the app",
              style:
                  TextStyle(color: AppColors.greyTextMutedLight, fontSize: 12)),
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
    BuildContext context,
    bool isDark,
  ) {
    return ListView(
      key: const ValueKey("content"),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 🌟 SECTION 1: CLOUD REALM (Network Bound Actions)
        _buildSectionHeader("CLOUD INTEGRATION"),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  // ref.read(backupViewModelProvider.notifier).uploadBackupToCloud();
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.12),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(Icons.cloud_upload_outlined,
                      color: AppColors.primaryBlue, size: 22),
                ),
                title: Text("Backup to Cloud Storage",
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Saves a secure copy of your data in cloud. Use this so you don't lose your information if your phone gets broken or lost",
                    style: TextStyle(
                        color: subtitleColor, fontSize: 12, height: 1.3),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.greyTextLight),
              ),
              Divider(height: 1, color: dividerColor),
              ListTile(
                onTap: () {
                  // ref.read(backupViewModelProvider.notifier).fetchBackupFromCloud();
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(Icons.cloud_download_outlined,
                      color: AppColors.primaryGreen, size: 22),
                ),
                title: Text("Restore from Cloud Target",
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Restore your saved cloud data back down to this phone. Perfect for setting up your app on a brand new device or recovering after a factory reset.",
                    style: TextStyle(
                        color: subtitleColor, fontSize: 12, height: 1.3),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.greyTextLight),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 🌟 SECTION 2: LOCAL ENVIRONMENT (Offline Sandbox Actions)
        _buildSectionHeader("LOCAL SANDBOX OPERATIONS"),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () => ref
                    .read(backupViewModelProvider.notifier)
                    .backupAndSyncAll(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: const Icon(Icons.add_to_photos_outlined,
                      color: AppColors.primaryBlue, size: 22),
                ),
                title: Text("Create Local Recovery Point",
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Makes a backup on your local device right now. You can use this to restore your data later.",
                    style: TextStyle(
                        color: subtitleColor, fontSize: 12, height: 1.3),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.greyTextLight),
              ),
              Divider(height: 1, color: dividerColor),
              ListTile(
                onTap: () => ref
                    .read(backupViewModelProvider.notifier)
                    .importAndRestoreFromFile(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: AppColors.accentGreenLight,
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  child: const Icon(Icons.file_open_outlined,
                      color: AppColors.primaryGreen, size: 22),
                ),
                title: Text("Import Backup File",
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Find and select a backup file saved on your phone to instantly load your past information back into the app.",
                    style: TextStyle(
                        color: subtitleColor, fontSize: 12, height: 1.3),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.greyTextLight),
              ),
            ],
          ),
        ),

        // SECTION 3: ARCHIVE ENTRIES
        if (uiState.localSnapshots.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader("AVAILABLE RESTORE POINTS"),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: uiState.localSnapshots.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final snapshot = uiState.localSnapshots[index];
              return Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkSurfaceAlt.withOpacity(0.6)
                        : AppColors.lightBorder.withOpacity(0.6),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.05 : 0.01),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.archive_outlined,
                                color: AppColors.accentOrange, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.name,
                                  style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: -0.1),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.data_usage_rounded,
                                        size: 12,
                                        color: subtitleColor.withOpacity(0.6)),
                                    const SizedBox(width: 4),
                                    Text(snapshot.formattedSize,
                                        style: TextStyle(
                                            color: subtitleColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 14),
                                    Icon(Icons.access_time_filled_rounded,
                                        size: 12,
                                        color: subtitleColor.withOpacity(0.6)),
                                    const SizedBox(width: 4),
                                    Text(snapshot.formattedTimestamp,
                                        style: TextStyle(
                                            color: subtitleColor,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: dividerColor),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_rounded,
                                color: AppColors.primaryBlue, size: 18),
                            tooltip: "Export Snapshot",
                            onPressed: () => ref
                                .read(backupViewModelProvider.notifier)
                                .exportSnapshotToFileSystem(snapshot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.dangerRed, size: 20),
                            tooltip: "Delete Archive",
                            onPressed: () =>
                                _confirmDeletion(context, ref, snapshot),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(backupViewModelProvider.notifier)
                                .restoreFromSnapshot(snapshot),
                            icon: const Icon(
                                Icons.settings_backup_restore_rounded,
                                size: 16),
                            label: const Text("Restore",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 10, top: 12),
        child: Text(
          label,
          style: const TextStyle(
              color: AppColors.greyTextLight,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8),
        ),
      ),
    );
  }
}

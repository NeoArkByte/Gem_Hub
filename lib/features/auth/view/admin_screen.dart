import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/features/auth/viewmodels/admin_screen_viewmodel.dart';
import 'package:gemhub/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/core/enums/gem_status.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/shared/widgets/custom_confirm_dialog.dart';
import 'package:gemhub/shared/widgets/custom_toast.dart';

class AdminReviewScreen extends ConsumerStatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  ConsumerState<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends ConsumerState<AdminReviewScreen> {
  final Color primaryGreen = AppColors.primaryGreen;

  String _selectedFilter = 'All';
  String _selectedGemFilter = 'All';

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const CustomConfirmDialog(
        title: 'Log Out',
        content: 'Are you sure you want to log out of the admin panel?',
        confirmLabel: 'Log Out',
        cancelLabel: 'Cancel',
        confirmColor: AppColors.dangerRed,
        icon: Icons.logout,
      ),
    );

    if (confirmed == true) {
      ref.read(authViewModelProvider.notifier).logout();
    }
  }

  void _showDeleteConfirmation(String jobId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const CustomConfirmDialog(
        title: 'Delete Job',
        content: 'Are you sure you want to permanently delete this job post?',
        confirmLabel: 'Delete',
        cancelLabel: 'Cancel',
        confirmColor: AppColors.dangerRed,
        icon: Icons.delete_outline,
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(adminScreenViewModelProvider.notifier)
          .deleteJob(jobId);

      if (success && mounted) {
        CustomToast.showError(context, 'Job Deleted Successfully! 🗑️');
      }
    }
  }

  void _showDeleteGemConfirmation(String gemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const CustomConfirmDialog(
        title: 'Delete Gem',
        content:
            'Are you sure you want to permanently delete this gem listing?',
        confirmLabel: 'Delete',
        cancelLabel: 'Cancel',
        confirmColor: AppColors.dangerRed,
        icon: Icons.delete_outline,
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(adminScreenViewModelProvider.notifier)
          .deleteGem(gemId);

      if (success && mounted) {
        CustomToast.showError(context, 'Gem Deleted Successfully! 🗑️');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final dividerColor =
        isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;
    final greyText = isDark ? Colors.grey[400]! : AppColors.greyText;

    final adminState = ref.watch(adminScreenViewModelProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAdminHeader(context, textColor),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dividerColor),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: TabBar(
                  indicatorColor: primaryGreen,
                  indicatorWeight: 3,
                  labelColor: textColor,
                  unselectedLabelColor: greyText,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: '💎 Gem Market'),
                    Tab(text: '💼 Job Market'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildGemMarketTab(adminState, cardBgColor, textColor,
                        dividerColor, greyText),
                    _buildJobMarketTab(adminState, cardBgColor, textColor,
                        dividerColor, greyText),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGemMarketTab(
    AsyncValue<AdminScreenState> stateAsync,
    Color cardBgColor,
    Color textColor,
    Color dividerColor,
    Color greyText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Gem Listing Management', Icons.diamond_outlined, greyText),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['All', 'Pending', 'Approved', 'Rejected'].map((filter) {
              final isSelected = _selectedGemFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ChoiceChip(
                  label: Text(filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : greyText),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      )),
                  selected: isSelected,
                  selectedColor: primaryGreen,
                  backgroundColor: cardBgColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedGemFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: stateAsync.when(
            loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGreen)),
            error: (error, stack) => Center(
                child:
                    Text('Error: $error', style: TextStyle(color: textColor))),
            data: (adminData) {
              final filteredGems = adminData.gems.where((gem) {
                if (_selectedGemFilter == 'All') return true;
                return gem.status.name.toLowerCase() ==
                    _selectedGemFilter.toLowerCase();
              }).toList();

              if (filteredGems.isEmpty) {
                return Center(
                  child: Text(
                      'No ${_selectedGemFilter.toLowerCase()} gems found.',
                      style: TextStyle(fontSize: 14, color: greyText)),
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredGems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildAdminGemCard(filteredGems[index], cardBgColor,
                      textColor, dividerColor, greyText);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminGemCard(
    Gem gem,
    Color cardBgColor,
    Color textColor,
    Color dividerColor,
    Color greyText,
  ) {
    Color statusColor = Colors.grey;
    if (gem.status == GemStatus.APPROVED) statusColor = primaryGreen;
    if (gem.status == GemStatus.PENDING) statusColor = Colors.orange;
    if (gem.status == GemStatus.REJECTED) statusColor = Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurfaceAlt
                      : Colors.grey[200],
                  child: gem.imageUrl != null && gem.imageUrl!.isNotEmpty
                      ? Image.network(gem.imageUrl!, fit: BoxFit.cover,
                          errorBuilder: (c, e, s) {
                          return const Icon(Icons.diamond, color: Colors.blue);
                        })
                      : const Icon(Icons.diamond, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gem.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${gem.variety ?? 'Unknown'} • ${gem.carat?.toStringAsFixed(2) ?? '0.00'} CT',
                      style: TextStyle(color: greyText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
                onPressed: () {
                  if (gem.gemId != null) {
                    _showDeleteGemConfirmation(gem.gemId!);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                gem.price != null
                    ? 'LKR ${gem.price!.toStringAsFixed(0)}'
                    : 'Negotiable',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  gem.status.name,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (gem.status == GemStatus.PENDING) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () async {
                      final success = await ref
                          .read(adminScreenViewModelProvider.notifier)
                          .updateGemStatus(gem, GemStatus.REJECTED);
                      if (success && mounted) {
                        CustomToast.showError(context, 'Gem Rejected ❌');
                      }
                    },
                    child: const Text('Reject', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () async {
                      final success = await ref
                          .read(adminScreenViewModelProvider.notifier)
                          .updateGemStatus(gem, GemStatus.APPROVED);
                      if (success && mounted) {
                        CustomToast.showSuccess(context, 'Gem Approved! ✅');
                      }
                    },
                    child:
                        const Text('Approve', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ] else if (gem.status == GemStatus.APPROVED) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.block, size: 16),
                label: const Text('Reject/De-approve',
                    style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  final success = await ref
                      .read(adminScreenViewModelProvider.notifier)
                      .updateGemStatus(gem, GemStatus.REJECTED);
                  if (success && mounted) {
                    CustomToast.showError(
                        context, 'Gem De-approved/Rejected ❌');
                  }
                },
              ),
            ),
          ] else if (gem.status == GemStatus.REJECTED) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label:
                    const Text('Approve Gem', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  final success = await ref
                      .read(adminScreenViewModelProvider.notifier)
                      .updateGemStatus(gem, GemStatus.APPROVED);
                  if (success && mounted) {
                    CustomToast.showSuccess(context, 'Gem Approved! ✅');
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobMarketTab(
    AsyncValue<AdminScreenState> stateAsync,
    Color cardBgColor,
    Color textColor,
    Color dividerColor,
    Color greyText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Job Post Management', Icons.work_outline, greyText),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['All', 'Pending', 'Approved', 'Rejected', 'Closed']
                .map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ChoiceChip(
                  label: Text(filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : greyText),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      )),
                  selected: isSelected,
                  selectedColor: primaryGreen,
                  backgroundColor: cardBgColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: stateAsync.when(
            loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryGreen)),
            error: (error, stack) => Center(
                child:
                    Text('Error: $error', style: TextStyle(color: textColor))),
            data: (adminData) {
              final filteredJobs = adminData.jobs.where((job) {
                if (_selectedFilter == 'All') return true;
                return job.status?.toLowerCase() ==
                    _selectedFilter.toLowerCase();
              }).toList();

              if (filteredJobs.isEmpty) {
                return Center(
                  child: Text('No ${_selectedFilter.toLowerCase()} jobs found.',
                      style: TextStyle(fontSize: 14, color: greyText)),
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredJobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildAdminJobCard(filteredJobs[index], cardBgColor,
                      textColor, dividerColor, greyText);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminJobCard(
    dynamic job,
    Color cardBgColor,
    Color textColor,
    Color dividerColor,
    Color greyText,
  ) {
    String currentStatus = job.status?.toLowerCase() ?? 'unknown';

    String salaryDisplay = 'Negotiable';
    if (job.minSalary != null && job.maxSalary != null) {
      salaryDisplay =
          'LKR ${job.minSalary!.toStringAsFixed(0)} - ${job.maxSalary!.toStringAsFixed(0)}';
    } else if (job.minSalary != null) {
      salaryDisplay = 'LKR ${job.minSalary!.toStringAsFixed(0)}';
    } else if (job.maxSalary != null) {
      salaryDisplay = 'LKR ${job.maxSalary!.toStringAsFixed(0)}';
    }

    Color statusColor = Colors.grey;
    if (currentStatus == 'approved') statusColor = primaryGreen;
    if (currentStatus == 'pending') statusColor = Colors.orange;
    if (currentStatus == 'rejected') statusColor = Colors.red;
    if (currentStatus == 'closed')
      statusColor = isDarkTheme ? Colors.white60 : Colors.black87;

    final String rawEmployerId = job.employerId ?? 'Unknown';
    final String employerIdDisplay =
        rawEmployerId != 'Unknown' && rawEmployerId.length > 8
            ? '${rawEmployerId.substring(0, 8)}...'
            : rawEmployerId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title ?? 'Unknown Job Title',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.blue, size: 20),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => context.push('/admin-edit-job',
                        extra: {'job': job, 'isAdmin': true}),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 20),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () {
                      if (job.jobId != null) {
                        _showDeleteConfirmation(job.jobId!);
                      }
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.business, size: 14, color: greyText),
                  const SizedBox(width: 4),
                  Text('ID: $employerIdDisplay',
                      style: TextStyle(color: greyText, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  (job.status ?? 'Unknown').toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              salaryDisplay,
              style: TextStyle(
                  color:
                      isDarkTheme ? AppColors.accentGreen : Colors.green[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
          if (currentStatus == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () async {
                      final success = await ref
                          .read(adminScreenViewModelProvider.notifier)
                          .updateJobStatus(job.jobId!, 'rejected');
                      if (success && mounted) {
                        CustomToast.showError(context, 'Job Rejected ❌');
                      }
                    },
                    child: const Text('Reject', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () async {
                      final success = await ref
                          .read(adminScreenViewModelProvider.notifier)
                          .updateJobStatus(job.jobId!, 'approved');
                      if (success && mounted) {
                        CustomToast.showSuccess(context, 'Job Approved! ✅');
                      }
                    },
                    child:
                        const Text('Approve', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ] else if (currentStatus == 'approved') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.block, size: 16),
                label: const Text('Close Job', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  final success = await ref
                      .read(adminScreenViewModelProvider.notifier)
                      .updateJobStatus(job.jobId!, 'closed');
                  if (success && mounted) {
                    CustomToast.showSuccess(
                        context, 'Job Closed Successfully 🔒');
                  }
                },
              ),
            ),
          ] else if (currentStatus == 'rejected') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label:
                    const Text('Approve Job', style: TextStyle(fontSize: 12)),
                onPressed: () async {
                  final success = await ref
                      .read(adminScreenViewModelProvider.notifier)
                      .updateJobStatus(job.jobId!, 'approved');
                  if (success && mounted) {
                    CustomToast.showSuccess(context, 'Job Approved! ✅');
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool get isDarkTheme => Theme.of(context).brightness == Brightness.dark;

  Widget _buildCustomAdminHeader(BuildContext context, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration:
                BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
            child: const CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=33')),
          ),
          const SizedBox(width: 12),
          Text('Admin Dashboard',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color greyText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: greyText),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: greyText)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:job_market/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:job_market/features/jobs/viewmodels/job_viewmodel.dart';

class AdminReviewScreen extends ConsumerStatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  ConsumerState<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends ConsumerState<AdminReviewScreen> {
        
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to log out of the admin panel?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // 1. Close Dialog
                Navigator.pop(dialogContext);

                // 2. ✅ Actual Logout Logic
                // This triggers the AuthViewModel which GoRouter is listening to
                ref.read(authViewModelProvider.notifier).logout();

                // 3. Optional: Navigation safety
                // Your GoRouter redirect handles the switch to /login,
                // but this check ensures no code runs if the user closed the app.
                if (!mounted) return;
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingJobsState = ref.watch(pendingJobsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // We removed the generic AppHeader here to allow this screen
      // to have its own unique Admin navigation/header logic.
      body: SafeArea(
        child: Column(
          children: [
            // Your custom admin-style header
            _buildCustomAdminHeader(context),

            _buildSectionHeader(
              'Pending Job Post Listings',
              Icons.hourglass_empty,
            ),

            Expanded(
              child: pendingJobsState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryYellow),
                ),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (pendingJobs) {
                  if (pendingJobs.isEmpty) {
                    return const Center(
                      child: Text(
                        'All caught up! No pending jobs.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: pendingJobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final job = pendingJobs[index];
                      // Return your card here...
                      return const SizedBox();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Unique Admin Header that replaces the standard app header
  Widget _buildCustomAdminHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.greyText),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
        ],
      ),
    );
  }
}

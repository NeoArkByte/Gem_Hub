import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/features/jobs/viewmodels/job_viewmodel.dart';
import 'package:job_market/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:job_market/features/jobs/viewmodels/job_viewmodel.dart';
import 'package:job_market/features/jobs/view/widgets/post_job_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:job_market/data/models/job_market/job_model.dart';
import 'package:job_market/features/auth/provider/session_provider.dart';
import 'package:job_market/features/jobs/viewmodels/post_job_viewmodel.dart';
import 'package:job_market/features/jobs/view/widgets/post_job_components.dart';

class AdminReviewScreen extends ConsumerStatefulWidget {
  const AdminReviewScreen({super.key});

  @override
  ConsumerState<AdminReviewScreen> createState() => _AdminReviewScreenState();
}

class _AdminReviewScreenState extends ConsumerState<AdminReviewScreen> {
  final Color primaryGreen = const Color(0xFF10C971);
  final Color primaryYellow = const Color(0xFFFDB913);
  final Color bgColor = const Color(0xFFF8F9FA);
  final Color greyText = const Color(0xFF6B7280);

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
                style: TextStyle(color: greyText, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authViewModelProvider.notifier).logout();
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
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAdminHeader(context),
            _buildSectionHeader(
              'Pending Job Post Listings',
              Icons.hourglass_empty,
            ),
            Expanded(
              child: pendingJobsState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFDB913)),
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
                      // ✅ Kalin SizedBox thibba thanata man aluth Card eka damma
                      return _buildPendingJobCard(job);
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

  /// ✅ Aluthin hadapu Job Card eka (Approve / Reject buttons ekkama)
  Widget _buildPendingJobCard(dynamic job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Title & Salary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title ?? 'Unknown Job Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LKR ${job.salary ?? 'N/A'}',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Employer Info (Optional: if you have company name)
          Row(
            children: [
              Icon(Icons.business, size: 16, color: greyText),
              const SizedBox(width: 4),
              Text(
                'Employer ID: ${job.employerId ?? 'Unknown'}',
                style: TextStyle(color: greyText, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons (Approve & Reject)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444), 
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Call Reject Action in ViewModel
                    //ref.read(jobViewModelProvider.notifier).updateJobStatus(job.id, 'REJECTED');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job Rejected')),
                    );
                  },
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Call Approve Action in ViewModel
                    ref.read(pendingJobsViewModelProvider.notifier).updateJobStatus(job.id, 'approved');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job Approved! Visible on market.')),
                    );
                  },
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAdminHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: primaryYellow,
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
          Icon(icon, size: 20, color: greyText),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: greyText,
            ),
          ),
        ],
      ),
    );
  }
}
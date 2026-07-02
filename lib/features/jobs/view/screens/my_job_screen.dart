import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/features/jobs/viewmodels/my_jobs_viewmodel.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  final Color primaryYellow = const Color(0xFFFDB913);
  final Color primaryGreen = const Color(0xFF10C971);

  // 💡 Popup එක පෙන්වන Function එක (මේක අනිවාර්යයෙන්ම _MyJobsScreenState ඇතුළේ තියෙන්න ඕනේ)
  void _showDeleteConfirmation(String jobId) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Job',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this job post? This action cannot be undone.',
            style: TextStyle(color: Colors.grey[500], height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);

                final success = await ref
                    .read(myJobsViewModelProvider.notifier)
                    .deleteJob(jobId);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job post deleted successfully! 🗑️'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete job!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Delete',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8F9FA);
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);

    final myJobsState = ref.watch(myJobsViewModelProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Job Posts',
          style: TextStyle(
              color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: myJobsState.when(
        data: (List<Job> myJobsList) {
          if (myJobsList.isEmpty) {
            return _buildEmptyState(isDark);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: myJobsList.length,
            itemBuilder: (context, index) {
              final job = myJobsList[index];
              return _buildMyJobCard(job, isDark);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF10C971)),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Failed to load jobs.\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Job Posts Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t posted any jobs.\nClick below to post a new job.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/post-job'),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text('Post a Job',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryYellow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyJobCard(Job job, bool isDark) {
    Color cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    Color borderColor = isDark ? const Color(0xFF374151) : Colors.grey[200]!;
    Color statusColor = job.status == 'Active' ? primaryGreen : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(
                    job.title.isNotEmpty ? job.title[0].toUpperCase() : 'J',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryYellow))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title ?? 'Job Title',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(job.companyInfo ?? 'Location',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(job.status ?? 'Pending',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ),
              ],
            ),
          ),
          // 💡 Edit & Delete Buttons දෙක එක ළඟ
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // 💡 Edit එක එබුවම Post Job Screen එකට Job එක අරන් යනවා
                  context.push('/post-job', extra: job);
                },
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                tooltip: 'Edit Job',
              ),
              IconButton(
                onPressed: () {
                  if (job.jobId != null) _showDeleteConfirmation(job.jobId!);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete Job',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

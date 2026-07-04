import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/features/auth/viewmodels/admin_all_jobs_viewmodel.dart';
import 'package:gemhub/features/auth/viewmodels/auth_viewmodel.dart';

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

  String _selectedFilter = 'All';

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Log Out',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              'Are you sure you want to log out of the admin panel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel',
                  style:
                      TextStyle(color: greyText, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                ref.read(authViewModelProvider.notifier).logout();
              },
              child: const Text('Log Out',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Delete Job',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
              'Are you sure you want to permanently delete this job post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);

                final success = await ref
                    .read(adminAllJobsViewModelProvider.notifier)
                    .deleteJob(jobId);

                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Job Deleted Successfully! 🗑️'),
                        backgroundColor: Colors.red),
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildCustomAdminHeader(context),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: TabBar(
                  indicatorColor: primaryYellow,
                  indicatorWeight: 3,
                  labelColor: Colors.black,
                  unselectedLabelColor: greyText,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  tabs: const [
                    Tab(text: '💎 Gem Market'),
                    Tab(text: '💼 Job Market'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildGemMarketTab(),
                    _buildJobMarketTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGemMarketTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.diamond_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Gem Marketplace Admin\n(Under Development)',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: greyText, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildJobMarketTab() {
    final allJobsState = ref.watch(adminAllJobsViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Job Post Management', Icons.work_outline),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ['All', 'Pending', 'Approved', 'Rejected', 'Closed']
                .map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter,
                      style: TextStyle(
                        color: isSelected ? Colors.black : greyText,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      )),
                  selected: isSelected,
                  selectedColor: primaryYellow,
                  backgroundColor: Colors.white,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: allJobsState.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFFFDB913))),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (allJobs) {
              final filteredJobs = allJobs.where((job) {
                if (_selectedFilter == 'All') return true;
                return job.status?.toLowerCase() ==
                    _selectedFilter.toLowerCase();
              }).toList();

              if (filteredJobs.isEmpty) {
                return Center(
                  child: Text('No ${_selectedFilter.toLowerCase()} jobs found.',
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                );
              }

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: filteredJobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildAdminJobCard(filteredJobs[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdminJobCard(dynamic job) {
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
    if (currentStatus == 'closed') statusColor = Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.blue, size: 22),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => context.push('/admin-edit-job',
                        extra: {'job': job, 'isAdmin': true}),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 22),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () {
                      if (job.jobId != null)
                        _showDeleteConfirmation(job.jobId!);
                    },
                  ),
                ],
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: greyText),
                  const SizedBox(width: 4),
                  Text('ID: ${job.employerId ?? 'Unknown'}',
                      style: TextStyle(color: greyText, fontSize: 13)),
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
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              salaryDisplay,
              style: TextStyle(
                  color: Colors.orange[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),

          if (currentStatus == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final success = await ref
                          .read(adminAllJobsViewModelProvider.notifier)
                          .updateJobStatus(job.jobId!, 'rejected');
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Job Rejected ❌'),
                                backgroundColor: Colors.red));
                      }
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
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final success = await ref
                          .read(adminAllJobsViewModelProvider.notifier)
                          .updateJobStatus(job.jobId!, 'approved');
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Job Approved! ✅'),
                                backgroundColor: Colors.green));
                      }
                    },
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ] else if (currentStatus == 'approved') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.black45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.block, size: 18),
                label: const Text('Close Job'),
                onPressed: () async {
                  final success = await ref
                      .read(adminAllJobsViewModelProvider.notifier)
                      .updateJobStatus(job.jobId!, 'closed');
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Job Closed Successfully 🔒'),
                        backgroundColor: Colors.black87));
                  }
                },
              ),
            ),
          ] else if (currentStatus == 'rejected') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Approve Job'),
                onPressed: () async {
                  final success = await ref
                      .read(adminAllJobsViewModelProvider.notifier)
                      .updateJobStatus(job.jobId!, 'approved');
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Job Approved! ✅'),
                        backgroundColor: Colors.green));
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomAdminHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration:
                BoxDecoration(color: primaryYellow, shape: BoxShape.circle),
            child: const CircleAvatar(
                radius: 22,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?img=33')),
          ),
          const SizedBox(width: 12),
          const Text('Admin Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          Text(title,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: greyText)),
        ],
      ),
    );
  }
}

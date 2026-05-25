import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:job_market/features/jobs/viewmodels/marketplace_viewmodel.dart';
import 'package:job_market/features/jobs/view/widgets/recent_job_card.dart';
import 'package:job_market/features/jobs/view/widgets/featured_job_card.dart';
import 'package:go_router/go_router.dart';

class FeaturedJobsList extends ConsumerWidget {
  const FeaturedJobsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsState = ref.watch(marketplaceViewModelProvider);

    return jobsState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF10C971)),
        ),
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (jobs) {
        final featuredJobs = jobs.take(3).toList();

        if (featuredJobs.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: featuredJobs.map((job) {
              
              // 💡 Salary පෙන්වන ලොජික් එක මෙතන හදලා තියාගන්නවා
              String displaySalary = 'Negotiable';
              if (job.minSalary != null && job.maxSalary != null) {
                displaySalary = 'LKR ${job.minSalary!.toStringAsFixed(0)} - ${job.maxSalary!.toStringAsFixed(0)}';
              } else if (job.minSalary != null) {
                displaySalary = 'LKR ${job.minSalary!.toStringAsFixed(0)}';
              } else if (job.maxSalary != null) {
                displaySalary = 'LKR ${job.maxSalary!.toStringAsFixed(0)}';
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => context.push('/job-details/${job.jobId}', extra: job),
                  child: FeaturedJobCard(
                    title: job.title,
                    company: job.companyInfo ?? 'Unknown Company',
                    salary: displaySalary, // 💡 අලුත් රේන්ජ් එක පාස් කරනවා
                    timePosted: 'New',
                    isPremium: true,
                    logoColor: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class RecentJobsList extends ConsumerWidget {
  const RecentJobsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsState = ref.watch(marketplaceViewModelProvider);

    return jobsState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF10C971)),
        ),
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (jobs) {
        if (jobs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40.0),
            child: Center(
              child: Text(
                'No jobs found.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];

              // 💡 Salary පෙන්වන ලොජික් එක මේකටත් දානවා
              String displaySalary = 'Negotiable';
              if (job.minSalary != null && job.maxSalary != null) {
                displaySalary = 'LKR ${job.minSalary!.toStringAsFixed(0)} - ${job.maxSalary!.toStringAsFixed(0)}';
              } else if (job.minSalary != null) {
                displaySalary = 'LKR ${job.minSalary!.toStringAsFixed(0)}';
              } else if (job.maxSalary != null) {
                displaySalary = 'LKR ${job.maxSalary!.toStringAsFixed(0)}';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () => context.push('/job-details/${job.jobId}', extra: job),
                  child: RecentJobCard(
                    title: job.title,
                    companyInfo: job.companyInfo ?? 'Unknown Company',
                    salary: displaySalary, // 💡 අලුත් රේන්ජ් එක පාස් කරනවා
                    tags: (job.tags).split(',').where((t) => t.isNotEmpty).toList(),
                    logoColor: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
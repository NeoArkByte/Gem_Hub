import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gemhub/features/jobs/viewmodels/marketplace_viewmodel.dart';
import 'package:gemhub/features/jobs/view/widgets/recent_job_card.dart';
import 'package:gemhub/features/jobs/view/widgets/featured_job_card.dart';


IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'gem cutter':
      return Icons.diamond_outlined;
    case 'polisher':
      return Icons.auto_fix_high;
    case 'gemologist':
      return Icons.search;
    case 'jewelry designer':
      return Icons.brush_outlined;
    case 'bench jeweler':
      return Icons.handyman_outlined;
    case 'diamond grader':
      return Icons.grade_outlined;
    case 'stone setter':
      return Icons.build_outlined;
    case 'appraiser':
      return Icons.verified_outlined;
    case 'sales executive':
      return Icons.storefront_outlined;
    case 'intern':
      return Icons.school_outlined;
    default:
      return Icons.work_outline;
  }
}

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
            
              String displaySalary = 'Negotiable';
              if (job.minSalary != null && job.maxSalary != null) {
                displaySalary =
                    'LKR ${job.minSalary!.toStringAsFixed(0)} - ${job.maxSalary!.toStringAsFixed(0)}';
              } else if (job.minSalary != null) {
                displaySalary =
                    'LKR ${job.minSalary!.toStringAsFixed(0)}';
              } else if (job.maxSalary != null) {
                displaySalary =
                    'LKR ${job.maxSalary!.toStringAsFixed(0)}';
              }

        
              final tagsList = (job.tags ?? '')
                  .split(',')
                  .where((t) => t.trim().isNotEmpty)
                  .toList();

              final String category =
                  tagsList.isNotEmpty ? tagsList.first : '';

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => context.push(
                    '/job-details/${job.jobId}',
                    extra: job,
                  ),
                  child: FeaturedJobCard(
                    title: job.title,
                    company: job.companyInfo ?? 'Unknown Company',
                    salary: displaySalary,
                    timePosted: 'New',
                    isPremium: true,
                    iconData: getCategoryIcon(category), 
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

          
              String displaySalary = 'Negotiable';
              if (job.minSalary != null && job.maxSalary != null) {
                displaySalary =
                    'LKR ${job.minSalary!.toStringAsFixed(0)} - ${job.maxSalary!.toStringAsFixed(0)}';
              } else if (job.minSalary != null) {
                displaySalary =
                    'LKR ${job.minSalary!.toStringAsFixed(0)}';
              } else if (job.maxSalary != null) {
                displaySalary =
                    'LKR ${job.maxSalary!.toStringAsFixed(0)}';
              }

            
              final tagsList = (job.tags ?? '')
                  .split(',')
                  .where((t) => t.trim().isNotEmpty)
                  .toList();

              final String category =
                  tagsList.isNotEmpty ? tagsList.first : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () => context.push(
                    '/job-details/${job.jobId}',
                    extra: job,
                  ),
                  child: RecentJobCard(
                    title: job.title,
                    companyInfo:
                        job.companyInfo ?? 'Unknown Company',
                    salary: displaySalary,
                    tags: tagsList,
                    iconData: getCategoryIcon(category), 
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
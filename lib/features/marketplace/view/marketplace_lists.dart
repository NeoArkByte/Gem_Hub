import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 👇 Imports tika hariyatama check karaganna bosa
import 'package:job_market/features/jobs/view/job_details.dart';
import 'package:job_market/features/marketplace/viewmodels/marketplace_viewmodel.dart';
import 'package:job_market/features/marketplace/view/recent_job_card.dart';
import 'package:job_market/features/jobs/view/featured_job_card.dart';

// =========================================================
// 1. FEATURED JOBS LIST (Newly Listed Jobs)
// =========================================================
class FeaturedJobsList extends ConsumerWidget {
  const FeaturedJobsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👇 ViewModel eken data tika live gannawa
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
        // 👇 Aluthma jobs 3 witharak "Newly Listed" ekata gannawa
        final featuredJobs = jobs.take(3).toList();

        if (featuredJobs.isEmpty) {
          return const SizedBox.shrink(); // Data natham mukuth pennanne na
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: featuredJobs
                .map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                JobDetailsScreen(job: job.toMap()),
                          ),
                        );
                      },
                      // 👇 ViewModel eken ena real data tika methanata pass karanawa
                      child: FeaturedJobCard(
                        title: job.title,
                        company: job.companyInfo,
                        salary: job.salary,
                        timePosted: 'New',
                        isPremium: true,
                        logoColor: Color(job.logoColor),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

// =========================================================
// 2. RECENT JOBS LIST (Explore All Jobs)
// =========================================================
class RecentJobsList extends ConsumerWidget {
  const RecentJobsList({Key? key}) : super(key: key);

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
          child: Column(
            children: jobs
                .map(
                  (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                JobDetailsScreen(job: job.toMap()),
                          ),
                        );
                      },
                      child: RecentJobCard(
                        title: job.title,
                        companyInfo: job.companyInfo,
                        salary: job.salary,
                        tags: job.tags.split(','),
                        logoColor: Color(job.logoColor),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

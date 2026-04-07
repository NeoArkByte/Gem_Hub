import 'package:flutter/material.dart';
import 'package:job_market/Screen/PostNewJob/post_new_job.dart';

// 👇 Import your separated widget files here! (Check your actual paths)
import 'package:job_market/widgets/marketplace_header.dart';
import 'package:job_market/widgets/marketplace_components.dart';
import 'package:job_market/widgets/marketplace_lists.dart';

class JobMarketplaceScreen extends StatelessWidget {
  const JobMarketplaceScreen({Key? key}) : super(key: key);

  final Color primaryGreen = const Color(0xFF10C971);

  @override
  Widget build(BuildContext context) {
    // 👇 Phone eke mode eka check karanawa
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 👇 Mode eka anuwa background color eka maru karanawa
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              MarketplaceHeader(),
              MarketplaceSearchBar(),
              MarketplaceCategories(),
              SectionHeader(title: 'Newly Listed Jobs', actionText: 'See All'),
              FeaturedJobsList(),
              SectionHeader(title: 'Explore All Jobs', icon: Icons.sort),
              RecentJobsList(),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PostJobScreen()),
        ),
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: const MarketplaceBottomNav(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:job_market/Screen/PostNewJob/post_new_job.dart';

// 👇 Import your separated widget files here! (Check your actual paths)
import 'package:job_market/widgets/marketplace_header.dart';
import 'package:job_market/widgets/marketplace_components.dart';
import 'package:job_market/widgets/marketplace_lists.dart';

class JobMarketplaceScreen extends StatefulWidget {
  const JobMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<JobMarketplaceScreen> createState() => _JobMarketplaceScreenState();
}

class _JobMarketplaceScreenState extends State<JobMarketplaceScreen> {
  final Color primaryGreen = const Color(0xFF10C971);

  int _bottomNavIndex = 3; 
  final TextEditingController _searchController = TextEditingController();
  
  // 👇 1. METHANA ALUTH VARIABLES DEKA DAMMA
  String _currentSearchQuery = "";
  String _currentCategory = "All Jobs";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MarketplaceHeader(),
              
              // 👇 2. SEARCH BAR EKATA SETSTATE DAMMA
              MarketplaceSearchBar(
                controller: _searchController,
                onSearchChanged: (value) {
                  setState(() {
                    _currentSearchQuery = value; // Type karaddi state eka update wela list eka refresh wenawa
                  });
                },
              ),
              
              // 👇 3. CATEGORIES WALATA SETSTATE DAMMA
              MarketplaceCategories(
                onCategorySelected: (category) {
                  setState(() {
                    _currentCategory = category; // Click kalama state eka update wela list eka refresh wenawa
                  });
                },
              ),
              
              const SectionHeader(title: 'Newly Listed Jobs', actionText: 'See All'),
              const FeaturedJobsList(),
              const SectionHeader(title: 'Explore All Jobs', icon: Icons.sort),
              
              // 👇 4. LOKUMA WENASA: 'const' eka ain karala Data pass kala!
              RecentJobsList(
                searchQuery: _currentSearchQuery,
                category: _currentCategory,
              ),
              
              const SizedBox(height: 80),
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
      bottomNavigationBar: MarketplaceBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
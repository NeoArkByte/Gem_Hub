import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 👇 Screens & ViewModels (Paths hariyatama check karaganna)
import 'package:job_market/features/auth/view/login_screen.dart';
import 'package:job_market/features/jobs/view/PostNewJob/post_new_job.dart';
import 'package:job_market/features/marketplace/viewmodels/marketplace_viewmodel.dart';

// 👇 Widgets
import 'package:job_market/features/marketplace/view/marketplace_header.dart';
import 'package:job_market/features/marketplace/view/marketplace_components.dart';
import 'package:job_market/features/marketplace/view/marketplace_lists.dart';

class JobMarketplaceScreen extends ConsumerStatefulWidget {
  const JobMarketplaceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobMarketplaceScreen> createState() =>
      _JobMarketplaceScreenState();
}

class _JobMarketplaceScreenState extends ConsumerState<JobMarketplaceScreen> {
  final Color primaryGreen = const Color(0xFF10C971);
  int _bottomNavIndex = 3;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('logged_in_user_id') != null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarketplaceHeader(isLoggedIn: _isLoggedIn),

              MarketplaceSearchBar(
                controller: _searchController,
                onSearchChanged: (value) {
                  // 👇 Text eka type karaddi ViewModel ekata yawanawa
                  ref
                      .read(marketplaceViewModelProvider.notifier)
                      .updateSearchQuery(value);
                },
              ),

              MarketplaceCategories(
                onCategorySelected: (category) {
                  // 👇 Category eka obaddi ViewModel ekata yawanawa
                  ref
                      .read(marketplaceViewModelProvider.notifier)
                      .updateCategory(category);
                },
              ),

              const SectionHeader(
                title: 'Newly Listed Jobs',
                actionText: 'See All',
              ),

              // 👇 Riverpod eken auto aluth jobs 3k gannawa (Parameters epa)
              const FeaturedJobsList(),

              const SectionHeader(title: 'Explore All Jobs', icon: Icons.sort),

              // 👇 Riverpod eken filter wechcha okkoma gannawa (Parameters epa)
              const RecentJobsList(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostJobScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to post a job')),
            );
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ).then((_) => _checkLoginStatus());
          }
        },
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}

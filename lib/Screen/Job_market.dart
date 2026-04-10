import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 👇 Screens
import 'package:job_market/Test/login_screen.dart';
import 'package:job_market/Screen/PostNewJob/post_new_job.dart';

// 👇 Widgets
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

  String _currentSearchQuery = "";
  String _currentCategory = "All Jobs";

  // 👇 ALUTH KALLA: Login State eka mathaka thiyaganna
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Screen eka lode weddi check karanawa
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 'logged_in_user_id' kiyala ekak thiyenawanam log wela kiyala hithanawa
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
              // 👇 Header ekata state eka yawanawa
              MarketplaceHeader(isLoggedIn: _isLoggedIn),

              MarketplaceSearchBar(
                controller: _searchController,
                onSearchChanged: (value) {
                  setState(() => _currentSearchQuery = value);
                },
              ),
              MarketplaceCategories(
                onCategorySelected: (category) {
                  setState(() => _currentCategory = category);
                },
              ),
              const SectionHeader(
                title: 'Newly Listed Jobs',
                actionText: 'See All',
              ),
              const FeaturedJobsList(),
              const SectionHeader(title: 'Explore All Jobs', icon: Icons.sort),
              RecentJobsList(
                searchQuery: _currentSearchQuery,
                category: _currentCategory,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // 👇 PLUS BUTTON EKA WENAS KALA (Login check karanawa)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PostJobScreen()),
            );
          } else {
            // Guest nam Login screen ekata yawanawa
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please log in to post a job')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        backgroundColor: primaryGreen,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      bottomNavigationBar: MarketplaceBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}

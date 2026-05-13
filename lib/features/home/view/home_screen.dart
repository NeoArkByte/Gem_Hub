import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_market/features/home/provider/portfolio_provider.dart';

import 'package:job_market/features/inventory/view/add_new_gemstone_inventory.dart';
import 'package:job_market/features/jobs/view/screens/post_new_job.dart';

import 'package:job_market/features/reports/presentation/views/reports_screen.dart';
import 'package:job_market/shared/widgets/app_header.dart';
// Remove the old manual mock and use the generated one
import 'package:job_market/features/home/provider/profile_view_model.dart';
import 'package:job_market/core/constants/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch both providers
    final profileState = ref.watch(profileViewModelProvider);
    final portfolioAsync = ref.watch(
      portfolioDataProvider,
    ); // Generated from your gemstone logic

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? AppColors.darkBackgroundAlt
        : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;

    return profileState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      ),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Connection Error: $err"))),
      data: (authenticatedUser) {
        // sessionProvider returns null if not logged in
        if (authenticatedUser == null) {
          return const Scaffold(body: Center(child: Text("Please Log In")));
        }

        final profile = authenticatedUser.profile;
        final email = authenticatedUser.supabaseUser?.email;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // You can pass the profile to your header if needed
                  const AppHeader(),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // This is your Gemstone Portfolio logic
                        portfolioAsync.when(
                          data: (portfolio) => _buildGoldenPortfolioCard(
                            totalInventoryValue:
                                portfolio['inventoryValue'] ?? 0.0,
                            realizedProfit: portfolio['realizedProfit'] ?? 0.0,
                            context: context,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 25),
                        // Display the username from the profile
                      

                        const SizedBox(height: 15),
                        _buildPerformanceTrends(textColor, isDark),
                        const SizedBox(height: 25),
                        _buildHeatmap(textColor, isDark),
                        const SizedBox(height: 25),
                        _buildQuickActions(context, isDark),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoldenPortfolioCard({
    required double totalInventoryValue, // Value of items in stock
    required double realizedProfit, // Actual profit from sold items
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.primaryYellow, AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CURRENT INVENTORY VALUE",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Stock",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "LKR ${NumberFormat('#,###').format(totalInventoryValue)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL REALIZED PROFIT",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "LKR ${NumberFormat('#,###').format(realizedProfit)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  children: [
                    Text("Details"),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. Performance Chart (Visual Simulation) ---
  Widget _buildPerformanceTrends(Color textColor, bool isDark) {
    return _buildCardWrapper(
      isDark,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance Trends",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Last 6 Months",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: ChartPainter()),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN']
                .map(
                  (m) => Text(
                    m,
                    style: TextStyle(
                      color: m == 'MAY' ? Colors.blue : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // --- 4. Heatmap Calendar (Visual Simulation) ---
  Widget _buildHeatmap(Color textColor, bool isDark) {
    return _buildCardWrapper(
      isDark,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Market Activity Heatmap",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              // TODO: Implement actual profit/loss gradient logic later
              // Dummy logic: random greens for profit, light greys for neutral
              Color tileColor = [
                AppColors.primaryGreen,
                AppColors.mintLight,
                AppColors.successMint,
              ][index % 3];
              return Container(
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              "Consistent profitability shown in emerald intensity",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Bottom Action Buttons ---
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            Icons.add_circle,
            "Add Gem",
            "Inventory Input",
            AppColors.blueSoft,
            AppColors.accentBlue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNewGemstoneScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            Icons.business_center,
            "Post Job",
            "Hire Talent",
            AppColors.mintLight,
            AppColors.darkGreen,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String title,
    String sub,
    Color bg,
    Color iconCol,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: iconCol,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: iconCol,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              sub,
              style: TextStyle(color: iconCol.withOpacity(0.6), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWrapper(bool isDark, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.textDarkAlt : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Custom Painter for the smooth curve chart
class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.9,
      size.width * 0.8,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
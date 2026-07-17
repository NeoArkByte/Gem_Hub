import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/shared/widgets/app_header.dart';
import 'package:gemhub/features/home/provider/profile_view_model.dart';
import 'package:gemhub/features/home/provider/home_chart_provider.dart';
import 'package:gemhub/features/home/provider/portfolio_provider.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/home/view/widgets/golden_portfolio_card.dart';
import 'package:gemhub/features/home/view/widgets/performance_trends_card.dart';
import 'package:gemhub/features/home/view/widgets/heatmap_card.dart';
import 'package:gemhub/features/home/view/widgets/quick_actions_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final portfolioAsync = ref.watch(portfolioDataProvider);
    final chartRange = ref.watch(chartRangeProvider);
    final chartTrendAsync = ref.watch(chartTrendDataProvider);
    final heatmapAsync = ref.watch(heatmapDataProvider);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;

    return profileState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      ),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Connection Error: $err"))),
      data: (authenticatedUser) {
        if (authenticatedUser == null) {
          return const Scaffold(body: Center(child: Text("Please Log In")));
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        portfolioAsync.when(
                          data: (portfolio) => GoldenPortfolioCard(
                            totalInventoryValue:
                                portfolio['inventoryValue'] ?? 0.0,
                            realizedProfit: portfolio['realizedProfit'] ?? 0.0,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 25),
                        const SizedBox(height: 15),
                        PerformanceTrendsCard(
                          textColor: textColor,
                          isDark: isDark,
                          chartRange: chartRange,
                          chartTrendAsync: chartTrendAsync,
                        ),
                        const SizedBox(height: 25),
                        HeatmapCard(
                          textColor: textColor,
                          isDark: isDark,
                          heatmapAsync: heatmapAsync,
                        ),
                        const SizedBox(height: 25),
                        QuickActionsSection(isDark: isDark),
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
}

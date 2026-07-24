import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/home/provider/home_chart_provider.dart';
import 'package:gemhub/features/home/view/widgets/card_wrapper.dart';

class HeatmapCard extends StatelessWidget {
  final Color textColor;
  final bool isDark;
  final AsyncValue<List<HeatmapCellData>> heatmapAsync;

  const HeatmapCard({
    super.key,
    required this.textColor,
    required this.isDark,
    required this.heatmapAsync,
  });

  @override
  Widget build(BuildContext context) {
    return HomeCardWrapper(
      isDark: isDark,
      child: Column(
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
          heatmapAsync.when(
            data: (cells) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 35,
                itemBuilder: (context, index) {
                  final cell = cells[index];

                  // Profit/loss gradient logic
                  Color tileColor;
                  if (cell.value > 0) {
                    // Positive value -> shades of green
                    tileColor = cell.value > 5000
                        ? AppColors.primaryGreen
                        : AppColors.successMint;
                  } else if (cell.value < 0) {
                    // Negative value -> shades of red
                    tileColor = Colors.red.shade400;
                  } else {
                    // Neutral / No value
                    tileColor =
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200;
                  }

                  // Fade out cells not in current month
                  if (!cell.isCurrentMonth) {
                    tileColor = tileColor.withOpacity(0.3);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(6),
                      border: !cell.isCurrentMonth
                          ? Border.all(
                              color: isDark ? Colors.white12 : Colors.black12)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${cell.date.day}',
                      style: TextStyle(
                        color: cell.isCurrentMonth
                            ? (tileColor == AppColors.primaryGreen ||
                                    tileColor == Colors.red.shade400 ||
                                    (isDark && cell.value == 0)
                                ? Colors.white
                                : Colors.black87)
                            : (isDark ? Colors.white38 : Colors.black38),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, st) => Center(
              child: Text(
                'Error loading heatmap',
                style: TextStyle(color: textColor),
              ),
            ),
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
}

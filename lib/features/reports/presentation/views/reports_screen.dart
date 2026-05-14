import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_market/data/models/inventory/gem_filter.dart';
import 'package:job_market/data/models/inventory/gemstone_model.dart';
import 'package:job_market/features/reports/presentation/view_models/report_view_model.dart';
import 'package:job_market/core/constants/app_colors.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  GemFilter _currentFilter = GemFilter();

  @override
  Widget build(BuildContext context) {
    final gemsAsync = ref.watch(
      filteredGemstonesProvider(filter: _currentFilter),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Inventory Report"), elevation: 0),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: gemsAsync.when(
              data: (gems) {
                // 1. Calculate the total using only current inventory value.
                // Sold gems should not contribute to the active portfolio total.
                final totalPortfolio = gems.fold<double>(
                  0,
                  (sum, gem) => sum + (gem.isSold ? 0.0 : gem.targetPrice),
                );

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // 2. Pass the freshly calculated total here
                      _buildTotalHeader(totalPortfolio),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: gems.length,
                        itemBuilder: (context, index) =>
                            _buildGemCard(gems[index]),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalHeader(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Total Portfolio Value",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "LKR ${total.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    // Watch the new varieties provider
    final varietiesAsync = ref.watch(gemstoneVarietiesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Date Filter (as before)
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(
                    () => _currentFilter = _currentFilter.copyWith(
                      dateRange: picked,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.calendar_month, size: 16),
              label: Text(
                _currentFilter.dateRange == null ? "Month" : "Filtered",
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Real Varieties Dropdown
          Expanded(
            flex: 3,
            child: varietiesAsync.when(
              data: (varieties) => DropdownButtonFormField<String>(
                initialValue: _currentFilter.variety ?? 'All',
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: "Variety",
                ),
                items: varieties
                    .map(
                      (val) => DropdownMenuItem(
                        value: val,
                        child: Text(val, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(
                    () => _currentFilter = _currentFilter.copyWith(
                      variety: value,
                    ),
                  );
                },
              ),
              // Show a simple text while loading varieties
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => const Text("Error"),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildGemCard(GemstoneModel gem) {
  // 1. Calculate Total Cost
  final double totalCost =
      gem.buyingPrice +
      gem.treatmentCost +
      gem.recutCost +
      gem.otherProcessingCost +
      gem.transportCost +
      gem.otherCost;

  // 2. Logic: If sold, use Selling Price. If not sold, use Target Price for "Potential Profit"
  final double displayProfit = gem.isSold
      ? (gem.sellingPrice - totalCost)
      : (gem.targetPrice - totalCost);

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Image Section with "SOLD" badge overlay
          Stack(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      gem.finalImagePath != null &&
                          gem.finalImagePath!.isNotEmpty
                      ? Image.file(
                          File(gem.finalImagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                        )
                      : const Icon(Icons.diamond, color: Colors.blueGrey),
                ),
              ),
              if (gem.isSold)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "SOLD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),

          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gem.variety,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gem.date,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),

          // Profit Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                gem.isSold ? "Profit" : "Target Profit",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                "LKR ${NumberFormat('#,###').format(displayProfit)}",
                style: TextStyle(
                  color: displayProfit >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
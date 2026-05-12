import 'package:job_market/data/models/inventory/gem_filter.dart';
import 'package:job_market/data/models/inventory/gemstone_model.dart';
import 'package:job_market/features/inventory/provider/inventory_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_view_model.g.dart';

/// Provider to fetch and filter gemstones based on UI selection
@riverpod
Future<List<GemstoneModel>> filteredGemstones(
  // ignore: deprecated_member_use_from_same_package
  Ref ref, {
  required GemFilter filter,
}) async {
  final gems = await ref.watch(inventoryProvider.future);

  return gems.where((gem) {
    if (filter.variety != null && filter.variety != 'All') {
      if (gem.variety != filter.variety) return false;
    }

    if (filter.dateRange != null) {
      final gemDate = DateTime.tryParse(gem.date);
      if (gemDate == null) return false;
      if (gemDate.isBefore(filter.dateRange!.start) ||
          gemDate.isAfter(filter.dateRange!.end)) {
        return false;
      }
    }

    return true;
  }).toList();
}

/// NEW: Provider to fetch unique varieties currently in the database
@riverpod
Future<List<String>> gemstoneVarieties(Ref ref) async {
  final gems = await ref.watch(inventoryProvider.future);

  final varieties = gems
      .map((gem) => gem.variety)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();

  varieties.sort();
  return ['All', ...varieties];
}

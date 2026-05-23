import 'package:gemhub/data/models/inventory/gem_filter.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_view_model.g.dart';

@riverpod
Future<List<GemstoneModel>> filteredGemstones(
  Ref ref, {
  required GemFilter filter,
}) async {
  final gems = await ref.watch(inventoryViewModelProvider.future);

  return gems.where((gem) {
    if (filter.variety != null && filter.variety != 'All') {
      if (gem.variety != filter.variety) return false;
    }

    if (filter.status != null && filter.status != 'All') {
      if (filter.status == 'Sold' && !gem.isSold) return false;
      if (filter.status == 'Available' && gem.isSold) return false;
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

@riverpod
Future<List<String>> gemstoneVarieties(Ref ref) async {
  final gems = await ref.watch(inventoryViewModelProvider.future);

  final varieties = gems
      .map((gem) => gem.variety)
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();

  varieties.sort();
  return ['All', ...varieties];
}

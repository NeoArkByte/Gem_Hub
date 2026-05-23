import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'portfolio_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<Map<String, double>> portfolioData(Ref ref) async {
  final gems = await ref.watch(inventoryViewModelProvider.future);

  double inventoryValue = 0;
  double realizedProfit = 0;

  for (var gem in gems) {
    final double totalCost =
        gem.buyingPrice +
        gem.treatmentCost +
        gem.recutCost +
        gem.otherProcessingCost +
        gem.transportCost +
        gem.otherCost;

    if (gem.isSold) {
      realizedProfit += gem.sellingPrice - totalCost;
    } else {
      inventoryValue += gem.targetPrice;
    }
  }

  return {'inventoryValue': inventoryValue, 'realizedProfit': realizedProfit};
}

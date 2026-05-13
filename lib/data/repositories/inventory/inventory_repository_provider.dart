import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'inventory_repository.dart';

part 'inventory_repository_provider.g.dart';

@riverpod
InventoryRepository inventoryRepository(Ref ref) {
  return InventoryRepository();
}

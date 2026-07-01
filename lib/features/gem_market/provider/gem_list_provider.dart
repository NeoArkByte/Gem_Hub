import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/repositories/gem_market/gem_repository_provider.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/core/enums/gem_status.dart';

part 'gem_list_provider.g.dart';

@riverpod
Future<List<Gem>> gemList(Ref ref) async {
  final sessionAsync = ref.watch(sessionProvider);
  final user = sessionAsync.value;

  if (user == null) return [];

  return await ref.read(gemRepositoryProvider).getAllGems();
}

@riverpod
Future<List<Gem>> approvedGems(Ref ref) async {
  final allGems = await ref.watch(gemListProvider.future);

  return allGems.where((gem) => gem.status == GemStatus.APPROVED).toList();
}

@riverpod
Future<List<Gem>> latestApprovedGems(Ref ref) async {
  final approvedGems = await ref.watch(approvedGemsProvider.future);

  return approvedGems.reversed.take(5).toList();
}

@riverpod
Future<List<Gem>> pendingGems(Ref ref) async {
  final allGems = await ref.watch(gemListProvider.future);

  return allGems.where((gem) => gem.status == GemStatus.PENDING).toList();
}

@riverpod
Future<List<Gem>> userSpecificGems(Ref ref) async {
  final sessionAsync = ref.watch(sessionProvider);
  final user = sessionAsync.value;

  if (user == null) return [];

  return await ref
      .read(gemRepositoryProvider)
      .getAllGemsByUserId(user.profile!.id);
}

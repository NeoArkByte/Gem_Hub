import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/core/providers/dio/dio_provider.dart';
import 'gem_repository.dart';

part 'gem_repository_provider.g.dart';

@riverpod
GemRepository gemRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return GemRepository(dio);
}
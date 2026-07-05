import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/core/providers/dio/dio_provider.dart';
import 'profile_repository.dart';

part 'profile_repository_provider.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
}
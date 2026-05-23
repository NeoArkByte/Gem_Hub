import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/core/providers/dio/dio_provider.dart';
import 'job_repository.dart';

part 'job_repository_provider.g.dart';

@riverpod
JobRepository jobRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return JobRepository(dio);
}
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/core/providers/dio/dio_provider.dart';
import 'cv_application_repository.dart';

part 'cv_application_repository_provider.g.dart';

@riverpod
CvApplicationRepository cvApplicationRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CvApplicationRepository(dio); 
}
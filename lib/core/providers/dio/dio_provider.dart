import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/core/api/supabase_auth_interceptor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:gemhub/core/providers/supabase/supabase_provider.dart';

part 'dio_provider.g.dart';

@riverpod
Dio dio(Ref ref) {
  final baseUrl = dotenv.env['API_BASE_URL'];

  if (baseUrl == null) {
    throw Exception("API_BASE_URL not found in .env file");
  }

  final supabaseClient = ref.watch(supabaseProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(SupabaseAuthInterceptor(supabaseClient));
  dio.interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: false,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 1000,
  ));

  return dio;
}

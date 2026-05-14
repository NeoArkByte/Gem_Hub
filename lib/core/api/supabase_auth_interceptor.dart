import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthInterceptor extends Interceptor {
  final SupabaseClient _supabase;

  SupabaseAuthInterceptor(this._supabase);

  @override
  void onRequest(
    RequestOptions options, 
    RequestInterceptorHandler handler
  ) async {
    final session = _supabase.auth.currentSession;

    if (session != null && session.isExpired) {
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        print('SupabaseAuthInterceptor: Session refresh failed: $e');
      }
    }

    final token = _supabase.auth.currentSession?.accessToken;
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      print('Auth Error: 401 Unauthorized. User session may have ended.');
    }
    return handler.next(err);
  }
}
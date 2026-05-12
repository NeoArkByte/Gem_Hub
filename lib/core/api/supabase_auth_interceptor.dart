import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthInterceptor extends Interceptor {
  final SupabaseClient _supabase;

  // Pass the client directly from your Provider
  SupabaseAuthInterceptor(this._supabase);

  @override
  void onRequest(
    RequestOptions options, 
    RequestInterceptorHandler handler
  ) async {
    final session = _supabase.auth.currentSession;

    // 1. Proactive Refresh
    // If the session exists but is expired, refresh it before sending the request
    if (session != null && session.isExpired) {
      try {
        await _supabase.auth.refreshSession();
      } catch (e) {
        // If refresh fails, we let the request continue; 
        // the backend 401 will trigger the onError logic.
        print('SupabaseAuthInterceptor: Session refresh failed: $e');
      }
    }

    // 2. Inject Token
    // We get the fresh token directly from the client we passed in
    final token = _supabase.auth.currentSession?.accessToken;
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue the request
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the backend rejects the token (401), handle it here
    if (err.response?.statusCode == 401) {
      print('Auth Error: 401 Unauthorized. User session may have ended.');
      // Optional: You could trigger a logout event here via an EventBus 
      // or a specific auth state provider.
    }
    return handler.next(err);
  }
}
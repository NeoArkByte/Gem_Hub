import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_market/data/models/auth/profile_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // ==========================================
  // ✅ AUTH ACTIONS
  // ==========================================

  /// Signs in a user with email and password.
  Future<User?> login(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.session == null) {
      throw Exception("Login failed: No active session created.");
    }

    return res.user;
  }

  /// Registers a new user with email and password.
  Future<User?> signUp(String email, String password) async {
    final res = await _client.auth.signUp(
      email: email, 
      password: password,
    );
    return res.user;
  }

  /// Initiates OAuth login flow (e.g., Google, Apple).
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  /// Signs out the current user and clears the session.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // ==========================================
  // ✅ PROFILE DATA
  // ==========================================

  /// Fetches profile metadata from the 'profiles' table for a specific user ID.
  Future<ProfileUser?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('profile_id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('AuthRepository: No profile found for UID: $userId');
        return null;
      }

      return ProfileUser.fromMap(response);
    } catch (e, stacktrace) {
      debugPrint('AuthRepository Error: Fetching profile failed.');
      debugPrint('Exception: $e');
      debugPrint('Stacktrace: $stacktrace');
      return null;
    }
  }

  // ==========================================
  // ✅ REACTIVE & GETTERS
  // ==========================================

  /// Stream of Auth changes (Login, Logout, Token Refresh).
  Stream<AuthState> get authState => _client.auth.onAuthStateChange;

  /// Returns the current Supabase [User] object if a session exists.
  User? get currentUser => _client.auth.currentUser;

  /// Returns the current [Session] metadata.
  Session? get currentSession => _client.auth.currentSession;

  /// Synchronous check to see if the user is currently authenticated.
  bool get isLoggedIn => _client.auth.currentSession != null;
}
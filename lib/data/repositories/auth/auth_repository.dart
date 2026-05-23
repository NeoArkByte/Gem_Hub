import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemhub/data/models/auth/profile_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  String get _webClientId {
    final key = dotenv.env['WEB_CLIENT'];
    if (key == null || key.isEmpty) {
      throw Exception('AuthRepository: WEB_CLIENT key is missing from your .env file!');
    }
    return key;
  }

  Future<User?> signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(serverClientId: _webClientId);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    final String? accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AuthException('Missing Google ID Token during authentication.');
    }

    final AuthResponse res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (res.session == null) {
      throw const AuthException('Supabase failed to initialize an active session.');
    }

    return res.user;
  }

  Future<User?> login(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.session == null) {
      throw const AuthException('Login failed: No active session created.');
    }

    return res.user;
  }

  Future<User?> signUp(String email, String password) async {
    final res = await _client.auth.signUp(
      email: email, 
      password: password,
    );
    return res.user;
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    await _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'io.supabase.flutter://login-callback',
    );
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
  }


  Future<ProfileUser?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('profile_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return ProfileUser.fromMap(response);
    } catch (_) {
      return null;
    }
  }


  Stream<AuthState> get authState => _client.auth.onAuthStateChange;
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => _client.auth.currentSession != null;
}
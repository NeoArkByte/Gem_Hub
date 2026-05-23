import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/repositories/auth/auth_repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_viewmodel.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<void> build() => null;

  Future<void> signInWithGoogleNative() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithGoogleNative();
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).login(email, password)
    );
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signUp(email, password)
    );
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithOAuth(provider)
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).logout()
    );
    
    if (ref.mounted) {
      state = result;
    }
  }

  String? validateLogin(String email, String password) {
    final emailError = _checkEmail(email);
    if (emailError != null) return emailError;

    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';

    return null;
  }

  String? validateSignUp(String email, String password, String confirmPassword) {
    final emailError = _checkEmail(email);
    if (emailError != null) return emailError;

    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != confirmPassword) return 'Passwords do not match';

    return null;
  }

  String? _checkEmail(String email) {
    if (email.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) return 'Enter a valid email address';
    return null;
  }
}
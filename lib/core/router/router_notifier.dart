import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/core/enums/user_role.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';

part 'router_notifier.g.dart';

@riverpod
RouterNotifier routerLogic(Ref ref) {
  return RouterNotifier(ref);
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final sessionAsync = _ref.read(sessionProvider);

    if (sessionAsync.isLoading && !sessionAsync.hasValue) return null;

    final user = sessionAsync.value;
    final bool isAuth = user?.supabaseUser != null;
    final userRole = user?.profile?.role;
    final String path = state.uri.path;
    final bool isGuestPage = path == '/login' || path == '/signup';


    // Unauthenticated User Logic
    if (!isAuth) {
      return isGuestPage ? null : '/login';
    }

    // Authenticated User Logic
    if (isAuth) {
      if (userRole == null) return null;

      // --- ADMIN AREA ---
      if (userRole == UserRole.ADMIN) {
        if (!path.startsWith('/admin')) {
          return '/admin';
        }
        return null;
      }

      // --- USER AREA ---
      if (userRole == UserRole.USER) {
        if (path.startsWith('/admin') || isGuestPage || path == '/') {
          return '/home';
        }
        return null; 
      }
    }

    return null;
  }
}

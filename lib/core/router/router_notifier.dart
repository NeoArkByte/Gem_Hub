import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/core/enums/user_role.dart';
import 'package:job_market/features/auth/provider/session_provider.dart';

part 'router_notifier.g.dart';

@riverpod
RouterNotifier routerLogic(Ref ref) {
  return RouterNotifier(ref);
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // We listen to the sessionProvider (The stable data)
    // Whenever the user logs in, logs out, or the profile loads, notify GoRouter.
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final sessionAsync = _ref.read(sessionProvider);

    // 1. Handle Initial Loading
    // While Supabase is checking for a persisted session on app launch, 
    // we return null to stay on the Splash/Initial screen.
    if (sessionAsync.isLoading) return null;

    final user = sessionAsync.value;
    final bool isAuth = user?.supabaseUser != null;
    final userRole = user?.profile?.role;

    final String path = state.uri.path;
    final bool isGuestPage = path == '/login' || path == '/signup';

    // 2. Guest Redirect Logic
    if (!isAuth) {
      // If not authenticated and not on a guest page, force login
      return isGuestPage ? null : '/login';
    }

    // 3. Authenticated Redirect Logic
    if (isAuth) {
      // If we are logged in but the profile data hasn't arrived yet, 
      // we wait (return null) to avoid routing based on a null role.
      if (userRole == null) {
        debugPrint('Router: Session exists, awaiting profile/role...');
        return null;
      }

      // Prevent logged-in users from visiting Login/Signup or the root
      if (isGuestPage || path == '/') {
        return (userRole == UserRole.ADMIN) ? '/admin' : '/home';
      }

      // Security: Prevent non-admins from accessing admin routes
      if (path.startsWith('/admin') && userRole != UserRole.ADMIN) {
        debugPrint('Security: Non-admin attempted to access admin route. Redirecting...');
        return '/home';
      }
    }

    return null; // No redirection needed
  }
}
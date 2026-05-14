import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_market/data/models/job_market/job_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/core/router/router_notifier.dart';

// View Imports
import 'package:job_market/features/navigation/view/main_navigation.dart';
import 'package:job_market/features/jobs/view/screens/job_market.dart';
import 'package:job_market/features/jobs/view/screens/post_new_job.dart';
import 'package:job_market/features/jobs/view/screens/job_details.dart';
import 'package:job_market/features/gem_market/view/gem_market_screen.dart';
import 'package:job_market/features/gem_market/view/gem_listing_screen.dart';
import 'package:job_market/features/gem_market/view/gem_market_add_entry.dart';
import 'package:job_market/features/auth/view/admin_screen.dart';
import 'package:job_market/features/auth/view/login_screen.dart';
import 'package:job_market/features/auth/view/sign_up_screen.dart';
import 'package:job_market/features/inventory/view/inventory_screen_view.dart';
import 'package:job_market/features/home/view/home_screen.dart';
import 'package:job_market/features/profile/view/profile_screen.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final notifier = ref.watch(routerLogicProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminReviewScreen(),
      ),

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/gems',
            name: 'gems',
            builder: (context, state) => const GemMarketPlaceScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'add_gem',
                builder: (context, state) => const AddGemScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/jobs',
            name: 'jobs',
            builder: (context, state) => const JobMarketplaceScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'post_job',
                builder: (context, state) => const PostJobScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/gem-details/:id',
        name: 'gem_details',
        builder: (context, state) {
          final gem = state.extra as Gem?;

          if (gem != null) {
            return GemListingDetailScreen(gem: gem);
          }

          return const Scaffold(
            body: Center(child: Text("Gem data not found")),
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/job-details/:id',
        name: 'job_details',
        builder: (context, state) {
          final job = state.extra as Job?;
          
          if (job != null) {
            return JobDetailsScreen(job: job);
          }

          return const Scaffold(
            body: Center(child: Text("Job details not found")),
          );
        },
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/core/router/router_notifier.dart';

import 'package:gemhub/features/navigation/view/main_navigation.dart';
import 'package:gemhub/features/jobs/view/screens/job_market.dart';
import 'package:gemhub/features/jobs/view/screens/post_new_job.dart';
import 'package:gemhub/features/jobs/view/screens/job_details.dart';
import 'package:gemhub/features/gem_market/view/screens/gem_market_screen.dart';
import 'package:gemhub/features/gem_market/view/screens/gem_market_inventory_screen.dart';
import 'package:gemhub/features/gem_market/view/screens/gem_listing_screen.dart';
import 'package:gemhub/features/gem_market/view/screens/gem_market_add_entry_screen.dart';
import 'package:gemhub/features/gem_market/view/screens/gem_market_update_entry_screen.dart';
import 'package:gemhub/features/auth/view/admin_screen.dart';
import 'package:gemhub/features/auth/view/login_screen.dart';
import 'package:gemhub/features/auth/view/sign_up_screen.dart';
import 'package:gemhub/features/inventory/view/inventory_screen_view.dart';
import 'package:gemhub/features/home/view/home_screen.dart';
import 'package:gemhub/features/profile/view/profile_screen.dart';
// Import your new feature view here
import 'package:gemhub/features/profile/view/backup_screen.dart';
import 'package:gemhub/features/inventory/view/gem_details_inventory_screen.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/jobs/view/screens/my_job_screen.dart';
import 'package:gemhub/features/other/view/help_center_screen.dart';
import 'package:gemhub/features/other/view/terms_privacy_screen.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {
  final notifier = ref.watch(routerLogicProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
      GoRoute(
        path: '/my-jobs',
        builder: (context, state) => const MyJobsScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
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
              GoRoute(
                path: 'edit/:id',
                name: 'edit_gem',
                builder: (context, state) {
                  final gem = state.extra as Gem?;
                  if (gem != null) {
                    return UpdateGemScreen(gem: gem);
                  }
                  return const Scaffold(
                    body: Center(child: Text('Gem not found')),
                  );
                },
              ),
              GoRoute(
                path: 'inventory',
                name: 'gem_market_inventory',
                builder: (context, state) => const GemMarketInventoryScreen(),
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
            routes: [
              GoRoute(
                path: 'details',
                name: 'inventory_details',
                builder: (context, state) {
                  final gem = state.extra as GemstoneModel;
                  return GemDetailsScreen(gemstone: gem);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // Added sub-route under /profile
              GoRoute(
                path: 'backup',
                name: 'backup',
                builder: (context, state) => const BackupScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/help-center',
            name: 'help_center',
            builder: (context, state) => const HelpCenterScreen(),
          ),
          GoRoute(
            path: '/terms-privacy',
            name: 'terms_privacy',
            builder: (context, state) => const TermsPrivacyScreen(),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
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
        parentNavigatorKey: rootNavigatorKey,
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
      GoRoute(
        path: '/post-job',
        builder: (context, state) {
          final jobToEdit = state.extra as Job?;
          return PostJobScreen(jobToEdit: jobToEdit);
        },
      ),
      GoRoute(
        path: '/admin-edit-job',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final job = data['job'] as Job?;
          return PostJobScreen(jobToEdit: job, isAdmin: true);
        },
      ),
    ],
  );
}

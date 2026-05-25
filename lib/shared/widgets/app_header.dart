import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  // Dynamic greeting based on the time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Watch sessionProvider for real-time Supabase user data
    final sessionAsync = ref.watch(sessionProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: sessionAsync.when(
        loading: () => const _HeaderSkeleton(), // Minimal loading state
        error: (err, stack) => const SizedBox.shrink(),
        data: (authData) {
          final profile = authData?.profile;
          final supabaseUser = authData?.supabaseUser;

          // Resolve username: Profile > Supabase Email Prefix > Guest
          final String userName = profile?.username ?? 
                                  supabaseUser?.email?.split('@')[0] ?? 
                                  'Guest';

          // Resolve avatar: Profile URL > DiceBear/Pravatar fallback
          final String avatarUrl = profile?.avatarUrl ?? 
                                  'https://i.pravatar.cc/150?u=${supabaseUser?.id ?? "guest"}';

          return Row(
            children: [
              // 1. Profile Avatar with the blue ring border
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.blueLight, // Light blue ring
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.peach, // Peachy background
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
              const SizedBox(width: 12),

              // 2. Dynamic Greeting and User Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? Colors.blueGrey[300]
                            : AppColors.greyTextMuted,
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textDarkAlt,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper for standard action buttons
  Widget _actionButton(IconData icon, VoidCallback onTap, bool isDark) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        icon,
        color: isDark ? Colors.white70 : AppColors.greyTextSecondary,
        size: 24,
      ),
    );
  }

  // Helper for the notification button with the red badge
  Widget _notificationButton(VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightBackgroundSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? Colors.white : AppColors.textDarkAlt,
              size: 22,
            ),
          ),
          // The red indicator dot
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.dangerRed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBackground : Colors.white,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple placeholder for when the user session is loading
class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 44, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
  }
}
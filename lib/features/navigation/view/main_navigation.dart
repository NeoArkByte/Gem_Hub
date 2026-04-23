import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/features/gem_market/view/gem_market.dart';
import 'package:job_market/features/navigation/viewmodel/navigation_viewmodel.dart';
import 'package:job_market/shared/widgets/bottom_navigation_bar.dart';
import 'package:job_market/shared/widgets/app_header.dart';

import 'package:job_market/features/marketplace/view/job_market.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  Future<bool> _onWillPop() async {
    final index = ref.read(navigationProvider);
    final navigator = _navigatorKeys[index].currentState!;

    if (navigator.canPop()) {
      navigator.pop();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      _buildTab(0, const JobMarketplaceScreen()),
      _buildTab(1, const JobMarketplaceScreen()),
      _buildTab(2, const GemMarketPlaceScreen()),
      _buildTab(3, const JobMarketplaceScreen()),
      _buildTab(4, const JobMarketplaceScreen()),
    ];

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF111827)
            : const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              // ─── Persistent header shown on ALL tabs ───
              Container(
                color: isDark
                    ? const Color(0xFF111827)
                    : const Color(0xFFF5F7FA),
                child: const AppHeader(),
              ),
              // ─── Tab content ───
              Expanded(
                child: IndexedStack(index: currentIndex, children: tabs),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => ref.read(navigationProvider.notifier).setIndex(i),
        ),
      ),
    );
  }

  Widget _buildTab(int index, Widget screen) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => screen),
    );
  }
}

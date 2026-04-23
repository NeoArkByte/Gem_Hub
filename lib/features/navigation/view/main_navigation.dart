import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/features/gem_market/view/gem_market.dart';
import 'package:job_market/features/navigation/viewmodel/navigation_viewmodel.dart';
import 'package:job_market/shared/widgets/bottom_navigation_bar.dart';

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

    final tabs = [
      _buildTab(0, const JobMarketplaceScreen()),
      _buildTab(1, const JobMarketplaceScreen()),
      _buildTab(2, const JobMarketplaceScreen()),
      _buildTab(3, const JobMarketplaceScreen()),
      _buildTab(4, const GemMarketPlaceScreen()),
    ];

    return PopScope(
      canPop: true,
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: tabs),
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

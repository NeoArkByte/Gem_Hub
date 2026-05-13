import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/core/enums/gem_type.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/features/gem_market/provider/gem_list_provider.dart';
import 'package:job_market/features/gem_market/viewmodel/gem_marketplace_viewmodel.dart';
import 'gem_market_add_entry.dart';
import 'package:job_market/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

// ─── Category model ────────────────────────────────────────────────────────────
class _Category {
  final GemType type;
  final String label;
  final IconData icon;
  final Color accentColor;
  const _Category(this.type, this.label, this.icon, this.accentColor);
}

const _categories = [
  _Category(
    GemType.allGems,
    'All Gems',
    Icons.auto_awesome_rounded,
    AppColors.primaryGreen,
  ),
  _Category(GemType.sapphire, 'Sapphire', Icons.circle, AppColors.accentGreen),
  _Category(GemType.ruby, 'Ruby', Icons.favorite_rounded, AppColors.dangerRed),
  _Category(
    GemType.emerald,
    'Emerald',
    Icons.eco_rounded,
    AppColors.accentGreen,
  ),
  _Category(
    GemType.diamond,
    'Diamond',
    Icons.diamond_rounded,
    AppColors.accentPurple,
  ),
  _Category(
    GemType.alexandrite,
    'Alexandrite',
    Icons.auto_fix_high_rounded,
    AppColors.accentPurple,
  ),
  _Category(
    GemType.topaz,
    'Topaz',
    Icons.brightness_high_rounded,
    AppColors.gold,
  ),
  _Category(
    GemType.spinel,
    'Spinel',
    Icons.grain_rounded,
    AppColors.accentPink,
  ),
  _Category(
    GemType.tourmaline,
    'Tourmaline',
    Icons.palette_rounded,
    AppColors.accentRed,
  ),
  _Category(
    GemType.other,
    'Other',
    Icons.more_horiz_rounded,
    AppColors.greyText,
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────
class GemMarketPlaceScreen extends ConsumerStatefulWidget {
  const GemMarketPlaceScreen({super.key});

  @override
  ConsumerState<GemMarketPlaceScreen> createState() =>
      _GemMarketPlaceScreenState();
}

class _GemMarketPlaceScreenState extends ConsumerState<GemMarketPlaceScreen> {
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackgroundAlt,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(),
          _CategoryFilter(),
          _LatestGemsSection(),
          _SectionHeader(),
          Expanded(child: _GemGrid()),
        ],
      ),
      floatingActionButton: _MarketFab(),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────────
  Widget _SearchBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.lightBorder,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.grey[400] : AppColors.greyText,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.darkBackground,
                        fontSize: 14,
                      ),
                      onChanged: (v) {
                        ref
                            .read(gemMarketplaceViewModelProvider.notifier)
                            .updateSearchQuery(v);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search rare sapphires, rubies...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : AppColors.greyText,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.lightBorder,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Latest Gems Section ───────────────────────────────────────────────────
  Widget _LatestGemsSection() {
    final latestGemsAsync = ref.watch(latestApprovedGemsProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return latestGemsAsync.when(
      loading: () => const SizedBox(height: 180),
      error: (err, stack) => const SizedBox.shrink(),
      data: (gems) {
        if (gems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Text(
                    'Latest Arrivals',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.darkBackground,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: gems.length,
                itemBuilder: (context, index) =>
                    _LatestGemCard(gem: gems[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _LatestGemCard({required Gem gem}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/gem-details/${gem.gemId}', extra: gem),
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceAlt
                : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: gem.imageUrl != null && gem.imageUrl!.isNotEmpty
                    ? Image.network(
                        gem.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                      )
                    : _ImagePlaceholder(),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gem.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${gem.carat ?? 0} Carat',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'LKR ${_fmt(gem.price)}',
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Glass Badge for Category
              Positioned(
                top: 12,
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        gem.variety!.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Categories ───────────────────────────────────────────────────────────────
  Widget _CategoryFilter() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(_categories.length, (i) {
            final cat = _categories[i];
            final isSelected = _selectedCategory == i;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = i);
                  // ref
                  //     .read(gemMarketplaceViewModelProvider.notifier)
                  //     .updateType(cat.type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : (isDark ? AppColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : (isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.lightBorder),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: isDark
                                  ? Colors.transparent
                                  : Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 13,
                        color: isSelected ? Colors.white : cat.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                    ? Colors.grey[300]
                                    : AppColors.greyText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────────
  Widget _SectionHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Explore Marketplace',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.darkBackground,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = 0);
              // ref
              //     .read(gemMarketplaceViewModelProvider.notifier)
              //     .updateType(GemType.allGems);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.primaryGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Gem Grid ─────────────────────────────────────────────────────────────────
  Widget _GemGrid() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final gemsState = ref.watch(gemMarketplaceViewModelProvider);

    return gemsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Error loading gems: $err',
          style: TextStyle(
            color: isDark ? Colors.redAccent.shade100 : Colors.red,
          ),
        ),
      ),
      data: (gems) {
        if (gems.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  color: isDark ? Colors.grey[400] : AppColors.greyText,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No gems found',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : AppColors.greyText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: gems.length,
          itemBuilder: (ctx, i) => _GemCard(gems[i]),
        );
      },
    );
  }

  Widget _GemCard(Gem gem) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/gem-details/${gem.gemId}', extra: gem),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceAlt
                : Colors.black.withOpacity(0.03),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with Overlays
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: gem.imageUrl != null && gem.imageUrl!.isNotEmpty
                        ? Image.network(
                            gem.imageUrl!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                          )
                        : _ImagePlaceholder(),
                  ),
                  // Favourite button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_border_rounded,
                            color: Color.fromARGB(255, 199, 206, 222),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gem.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.darkBackground,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${gem.carat ?? 0} CT',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'LKR ${_fmt(gem.price)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────────
  Widget _MarketFab() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddGemScreen()),
            );
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  String _fmt(double? price) {
    if (price == null) return '0';
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

Widget _ImagePlaceholder() {
  return Container(
    color: AppColors.accentGreenLight,
    child: const Center(
      child: Icon(Icons.diamond, color: AppColors.primaryGreen, size: 40),
    ),
  );
}

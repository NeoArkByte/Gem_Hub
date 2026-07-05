import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/enums/gem_type.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/features/gem_market/viewmodel/gem_market/gem_marketplace_viewmodel.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

//  Main Screen
class GemMarketPlaceScreen extends ConsumerStatefulWidget {
  const GemMarketPlaceScreen({super.key});

  @override
  ConsumerState<GemMarketPlaceScreen> createState() =>
      _GemMarketPlaceScreenState();
}

class _GemMarketPlaceScreenState extends ConsumerState<GemMarketPlaceScreen> {
  GemType _selectedCategory = GemType.allGems;
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
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackgroundAlt,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: 12)),
          SliverToBoxAdapter(child: _SearchBar()),
          SliverToBoxAdapter(child: _CategoryFilter()),
          SliverToBoxAdapter(child: _LatestGemsSection()),
          SliverToBoxAdapter(child: _SectionHeader()),
          _GemGrid(),
        ],
      ),
    );
  }

  //  Search Bar
  Widget _SearchBar() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  color:
                      isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
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
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
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
          ),
        ],
      ),
    );
  }

  //  Latest Gems Section
  Widget _LatestGemsSection() {
    final gemsAsync = ref.watch(gemMarketplaceViewModelProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
        gemsAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          ),
          error: (err, stack) => const SizedBox.shrink(),
          data: (gems) {
            final latestGems = gems.reversed.take(5).toList();

            if (latestGems.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No latest arrivals matching filters',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : AppColors.greyText,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: latestGems.length,
                itemBuilder: (context, index) =>
                    _LatestGemCard(gem: latestGems[index]),
              ),
            );
          },
        ),
      ],
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

  //  Categories
  Widget _CategoryFilter() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        height: 50,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemCount: GemType.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final type = GemType.values[index];
            final selected = _selectedCategory == type;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: selected,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  setState(() => _selectedCategory = type);
                  ref
                      .read(gemMarketplaceViewModelProvider.notifier)
                      .updateSelectedCategory(type);
                }
              },
              selectedColor: AppColors.primaryGreen,
              backgroundColor:
                  isDark ? AppColors.darkSurface : AppColors.lightSurface,
              side: BorderSide(
                color: selected
                    ? Colors.transparent
                    : (isDark
                        ? AppColors.darkSurfaceAlt
                        : AppColors.lightBorderAlt),
              ),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : (isDark ? AppColors.greyTextLight : AppColors.textDark),
              ),
            );
          },
        ),
      ),
    );
  }

  //  Section Header
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
              setState(() => _selectedCategory = GemType.allGems);
              ref
                  .read(gemMarketplaceViewModelProvider.notifier)
                  .updateSelectedCategory(GemType.allGems);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color:
                    isDark ? AppColors.darkSurface : AppColors.accentGreenLight,
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

  //  Gem Grid
  Widget _GemGrid() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final gemsState = ref.watch(gemMarketplaceViewModelProvider);

    return gemsState.when(
      loading: () => const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      ),
      error: (err, stack) => SliverFillRemaining(
        child: Center(
          child: Text(
            'Error loading gems: $err',
            style: TextStyle(
              color: isDark ? Colors.redAccent.shade100 : Colors.red,
            ),
          ),
        ),
      ),
      data: (gems) {
        if (gems.isEmpty) {
          return SliverFillRemaining(
            child: Center(
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
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _GemCard(gems[i]),
              childCount: gems.length,
            ),
          ),
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
                      color: isDark ? Colors.white : AppColors.textDarkAlt,
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

  String _fmt(double? price) {
    if (price == null) return '0';
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final notifier = ref.read(gemMarketplaceViewModelProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FilterBottomSheet(
          initialMinWeight: notifier.minWeight,
          initialMaxWeight: notifier.maxWeight,
          initialColor: notifier.selectedColor,
          initialMinPrice: notifier.minPrice,
          initialMaxPrice: notifier.maxPrice,
          onApply: (minW, maxW, color, minP, maxP) {
            notifier.updateFilters(
              minWeight: minW,
              maxWeight: maxW,
              selectedColor: color,
              minPrice: minP,
              maxPrice: maxP,
            );
          },
          onReset: () {
            notifier.resetFilters();
          },
        );
      },
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

class _FilterBottomSheet extends StatefulWidget {
  final double? initialMinWeight;
  final double? initialMaxWeight;
  final String? initialColor;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final void Function(
    double? minWeight,
    double? maxWeight,
    String? color,
    double? minPrice,
    double? maxPrice,
  ) onApply;
  final VoidCallback onReset;

  const _FilterBottomSheet({
    this.initialMinWeight,
    this.initialMaxWeight,
    this.initialColor,
    this.initialMinPrice,
    this.initialMaxPrice,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late final TextEditingController _minWeightController;
  late final TextEditingController _maxWeightController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  late final TextEditingController _customColorController;

  String? _selectedColor;
  final List<String> _popularColors = const [
    'Blue',
    'Red',
    'Green',
    'Yellow',
    'White',
    'Pink'
  ];

  @override
  void initState() {
    super.initState();
    _minWeightController =
        TextEditingController(text: widget.initialMinWeight?.toString() ?? '');
    _maxWeightController =
        TextEditingController(text: widget.initialMaxWeight?.toString() ?? '');
    _minPriceController = TextEditingController(
      text: widget.initialMinPrice != null
          ? widget.initialMinPrice!.toStringAsFixed(0)
          : '',
    );
    _maxPriceController = TextEditingController(
      text: widget.initialMaxPrice != null
          ? widget.initialMaxPrice!.toStringAsFixed(0)
          : '',
    );
    _customColorController = TextEditingController();

    if (widget.initialColor != null && widget.initialColor!.isNotEmpty) {
      final matched = _popularColors.firstWhere(
        (c) => c.toLowerCase() == widget.initialColor!.toLowerCase(),
        orElse: () => '',
      );
      if (matched.isNotEmpty) {
        _selectedColor = matched;
      } else {
        _selectedColor = 'Other';
        _customColorController.text = widget.initialColor!;
      }
    }
  }

  @override
  void dispose() {
    _minWeightController.dispose();
    _maxWeightController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _customColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
          width: 1,
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Listings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      color: AppColors.dangerRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionHeader('Weight (Carats)', isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _minWeightController,
                    hint: 'Min Carat',
                    isDark: isDark,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    icon: Icons.scale_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _maxWeightController,
                    hint: 'Max Carat',
                    isDark: isDark,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    icon: Icons.scale_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Gemstone Color', isDark),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _popularColors.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == _popularColors.length) {
                    final selected = _selectedColor == 'Other' ||
                        (_selectedColor != null &&
                            !_popularColors.contains(_selectedColor));
                    return ChoiceChip(
                      label: const Text('Other'),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (val) {
                        setState(() {
                          _selectedColor = val ? 'Other' : null;
                        });
                      },
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      side: BorderSide(
                        color: selected
                            ? Colors.transparent
                            : (isDark
                                ? AppColors.darkSurfaceAlt
                                : AppColors.lightBorder),
                      ),
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : (isDark ? Colors.white70 : AppColors.textDark),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }

                  final colorName = _popularColors[index];
                  final selected = _selectedColor == colorName;
                  return ChoiceChip(
                    label: Text(colorName),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (val) {
                      setState(() {
                        _selectedColor = val ? colorName : null;
                      });
                    },
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    side: BorderSide(
                      color: selected
                          ? Colors.transparent
                          : (isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.lightBorder),
                    ),
                    labelStyle: TextStyle(
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.textDark),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            if (_selectedColor == 'Other') ...[
              const SizedBox(height: 12),
              _buildTextField(
                controller: _customColorController,
                hint: 'Enter custom color (e.g. Padparadscha)',
                isDark: isDark,
                keyboardType: TextInputType.text,
                icon: Icons.palette_outlined,
              ),
            ],
            const SizedBox(height: 20),
            _buildSectionHeader('Price Range (LKR)', isDark),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _minPriceController,
                    hint: 'Min Price',
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _maxPriceController,
                    hint: 'Max Price',
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                    icon: Icons.monetization_on_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  final minW = double.tryParse(_minWeightController.text);
                  final maxW = double.tryParse(_maxWeightController.text);

                  String? finalColor;
                  if (_selectedColor == 'Other') {
                    finalColor = _customColorController.text.trim();
                  } else {
                    finalColor = _selectedColor;
                  }

                  if (finalColor != null && finalColor.isEmpty) {
                    finalColor = null;
                  }

                  final minP = double.tryParse(_minPriceController.text);
                  final maxP = double.tryParse(_maxPriceController.text);

                  widget.onApply(minW, maxW, finalColor, minP, maxP);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.grey[300] : AppColors.textDarkAlt,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.darkBackground : AppColors.lightBackgroundGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textDark,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.grey[500] : AppColors.greyText,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: isDark ? Colors.grey[400] : AppColors.greyText,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

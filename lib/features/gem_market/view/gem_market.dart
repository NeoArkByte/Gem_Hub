import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/core/enums/gem_type.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/features/gem_market/viewmodel/gem_marketplace_viewmodel.dart';
import 'gem_marketplace_widgets.dart';
import 'gem_market_add_entry.dart';

// ─── Category model ────────────────────────────────────────────────────────────
class _Category {
  final GemType type;
  final String label;
  final IconData icon;
  final Color accentColor;
  const _Category(this.type, this.label, this.icon, this.accentColor);
}

const _categories = [
  _Category(GemType.allGems, 'All Gems', Icons.auto_awesome_rounded, Color(0xFF10C971)),
  _Category(GemType.sapphire, 'Sapphire', Icons.circle, Color(0xFF10B981)),
  _Category(GemType.ruby, 'Ruby', Icons.favorite_rounded, Color(0xFFEF4444)),
  _Category(GemType.emerald, 'Emerald', Icons.eco_rounded, Color(0xFF10B981)),
  _Category(GemType.diamond, 'Diamond', Icons.diamond_rounded, Color(0xFF8B5CF6)),
  _Category(GemType.alexandrite, 'Alexandrite', Icons.auto_fix_high_rounded, Color(0xFF8B5CF6)),
  _Category(GemType.topaz, 'Topaz', Icons.brightness_high_rounded, Color(0xFFF59E0B)),
  _Category(GemType.spinel, 'Spinel', Icons.grain_rounded, Color(0xFFEC4899)),
  _Category(GemType.tourmaline, 'Tourmaline', Icons.palette_rounded, Color(0xFFF43F5E)),
  _Category(GemType.other, 'Other', Icons.more_horiz_rounded, Color(0xFF6B7280)),
];

// ─── Light theme design tokens ────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF10C971);
  static const accentLight = Color(0xFFDCFCE7);
  static const gold = Color(0xFFF59E0B);
  static const text = Color(0xFF111827);
  static const subText = Color(0xFF6B7280);
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class GemMarketPlaceScreen extends ConsumerStatefulWidget {
  const GemMarketPlaceScreen({super.key});

  @override
  ConsumerState<GemMarketPlaceScreen> createState() => _GemMarketPlaceScreenState();
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

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111827) : _T.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(),
          _buildSearchBar(),
          _buildCategories(),
          _buildSectionHeader(),
          Expanded(child: _buildGemGrid()),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // ─── Hero Header ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : _T.text,
            height: 1.25,
          ),
          children: const [
            TextSpan(text: 'Find Your '),
            TextSpan(
              text: 'Exquisite',
              style: TextStyle(color: _T.accent),
            ),
            TextSpan(text: '\nEternal Sparkle'),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
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
                color: isDark ? const Color(0xFF1F2937) : _T.card,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isDark ? const Color(0xFF374151) : _T.border),
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
                  Icon(Icons.search_rounded, color: isDark ? Colors.grey[400] : _T.subText, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: isDark ? Colors.white : _T.text, fontSize: 14),
                      onChanged: (v) {
                        ref.read(gemMarketplaceViewModelProvider.notifier).updateSearchQuery(v);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search rare sapphires, rubies...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : _T.subText, fontSize: 14),
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
              color: isDark ? const Color(0xFF1F2937) : _T.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? const Color(0xFF374151) : _T.border),
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
            child: const Icon(Icons.tune_rounded, color: _T.accent, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Categories ───────────────────────────────────────────────────────────────
  Widget _buildCategories() {
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
                  ref.read(gemMarketplaceViewModelProvider.notifier).updateType(cat.type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _T.accent : (isDark ? const Color(0xFF1F2937) : _T.card),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _T.accent : (isDark ? const Color(0xFF374151) : _T.border),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _T.accent.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: isDark ? Colors.transparent : Colors.black.withOpacity(0.03),
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
                          color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : _T.subText),
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
  Widget _buildSectionHeader() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'New Arrivals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : _T.text,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = 0);
              ref.read(gemMarketplaceViewModelProvider.notifier).updateType(GemType.allGems);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : _T.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : _T.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Gem Grid ─────────────────────────────────────────────────────────────────
  Widget _buildGemGrid() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final gemsState = ref.watch(gemMarketplaceViewModelProvider);

    return gemsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: _T.accent),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Error loading gems: $err',
          style: TextStyle(color: isDark ? Colors.redAccent.shade100 : Colors.red),
        ),
      ),
      data: (gems) {
        if (gems.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, color: isDark ? Colors.grey[400] : _T.subText, size: 48),
                const SizedBox(height: 12),
                Text('No gems found',
                    style: TextStyle(color: isDark ? Colors.grey[400] : _T.subText, fontSize: 16)),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: gems.length,
          itemBuilder: (ctx, i) => _buildGemCard(gems[i]),
        );
      },
    );
  }

  Widget _buildGemCard(Gem gem) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => ListingDetailScreen(gem: gem)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : _T.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF374151) : _T.border),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      gem.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _T.accentLight,
                        child: const Center(
                          child:
                              Icon(Icons.diamond, color: _T.accent, size: 40),
                        ),
                      ),
                    ),
                  ),
                  // Favourite button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          color: _T.subText,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gem.type.displayName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _T.gold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    gem.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : _T.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_fmt(gem.price)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _T.accent,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.star_rounded, color: _T.gold, size: 13),
                          SizedBox(width: 2),
                          Text(
                            '5.0',
                            style: TextStyle(
                              fontSize: 11,
                              color: _T.subText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
  Widget _buildFab() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _T.accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _T.accent.withOpacity(0.35),
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
                MaterialPageRoute(builder: (_) => AddGemScreen()),
              );
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  String _fmt(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

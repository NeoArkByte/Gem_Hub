import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/core/enums/gem_status.dart';
import 'package:gemhub/core/enums/gem_type.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/features/gem_market/viewmodel/gem_market_inventory_viewmodel.dart';

class GemMarketInventoryScreen extends ConsumerStatefulWidget {
  const GemMarketInventoryScreen({super.key});

  @override
  ConsumerState<GemMarketInventoryScreen> createState() =>
      _GemMarketInventoryScreenState();
}

class _GemMarketInventoryScreenState
    extends ConsumerState<GemMarketInventoryScreen> {
  GemType _selectedCategory = GemType.allGems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── MAIN BUILD ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final gemsAsync = ref.watch(gemMarketInventoryViewModelProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.diamond, color: AppColors.primaryGreen, size: 24),
            const SizedBox(width: 8),
            Text(
              'Gem Market Inventory',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: gemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Unable to load inventory: $error')),
        data: (gems) {
          // Filtered groupings for evaluation calculations
          final approvedGems = gems.where((gem) => gem.status == GemStatus.APPROVED);
          final pendingGems = gems.where((gem) => gem.status == GemStatus.PENDING);
          final rejectedGems = gems.where((gem) => gem.status == GemStatus.REJECTED);

          // Cumulative Prices Valuation
          final approvedValue = approvedGems.fold<double>(0, (sum, gem) => sum + (gem.price ?? 0));
          final pendingValue = pendingGems.fold<double>(0, (sum, gem) => sum + (gem.price ?? 0));
          final rejectedValue = rejectedGems.fold<double>(0, (sum, gem) => sum + (gem.price ?? 0));

          final contentChildren = <Widget>[
            const SizedBox(height: 16),
            _buildSummaryCard(
              isDark: isDark,
              approvedCount: approvedGems.length,
              pendingCount: pendingGems.length,
              rejectedCount: rejectedGems.length,
              approvedValue: approvedValue,
              pendingValue: pendingValue,
              rejectedValue: rejectedValue,
            ),
            _buildSearchBar(isDark),
            _buildCategoryChips(isDark),
            const SizedBox(height: 8),
          ];

          if (gems.isEmpty) {
            contentChildren.add(
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No market gems found.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : AppColors.greyText,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          } else {
            contentChildren.addAll(
              gems.map((gem) => _buildInventoryCard(context, gem, isDark)),
            );
            contentChildren.add(const SizedBox(height: 16));
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: contentChildren,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/gems/new'),
        backgroundColor: AppColors.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // ─── PREMIUM CARD DESIGN ───────────────────────────────────────────────────

  Widget _buildSummaryCard({
    required bool isDark,
    required int approvedCount,
    required int pendingCount,
    required int rejectedCount,
    required double approvedValue,
    required double pendingValue,
    required double rejectedValue,
  }) {
    final int totalCount = approvedCount + pendingCount + rejectedCount;
    final double totalValue = approvedValue + pendingValue + rejectedValue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkGreenDeep,
              Color(0xFF0A4D39),
              AppColors.darkGreen,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreenDeep.withOpacity(isDark ? 0.3 : 0.45),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.16), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen.withOpacity(0.15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics_rounded,
                              size: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'GEM INVENTORY OVERVIEW',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 11,
                                letterSpacing: 1.6,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Items: $totalCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LKR ${_formatPrice(totalValue)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'TOTAL PORTFOLIO VALUE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatMetric(
                            'Approved',
                            approvedCount,
                            approvedValue,
                            AppColors.successGreen,
                          ),
                          _buildDivider(),
                          _buildStatMetric(
                            'Pending',
                            pendingCount,
                            pendingValue,
                            AppColors.gold,
                          ),
                          _buildDivider(),
                          _buildStatMetric(
                            'Rejected',
                            rejectedCount,
                            rejectedValue,
                            AppColors.dangerRed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatMetric(String label, int count, double value, Color metricColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'LKR ${_formatCompactPrice(value)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: metricColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 35,
      width: 1,
      color: Colors.white.withOpacity(0.12),
    );
  }

  // ─── SEARCH & CARDS UI ─────────────────────────────────────────────────────

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
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
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            return Row(
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
                      color: isDark ? Colors.white : AppColors.textDark,
                      fontSize: 14,
                    ),
                    onChanged: (text) {
                      ref
                          .read(gemMarketInventoryViewModelProvider.notifier)
                          .updateSearchQuery(text);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search market gems, varieties, or location...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : AppColors.greyText,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (value.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref
                          .read(gemMarketInventoryViewModelProvider.notifier)
                          .updateSearchQuery('');
                    },
                    child: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[400] : AppColors.greyText,
                      size: 20,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    final categories = GemType.values.take(6).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SizedBox(
        height: 50,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final category = categories[index];
            final selected = category == _selectedCategory;
            return ChoiceChip(
              label: Text(category.displayName),
              selected: selected,
              showCheckmark: false,
              onSelected: (value) {
                if (value) {
                  setState(() => _selectedCategory = category);
                  ref
                      .read(gemMarketInventoryViewModelProvider.notifier)
                      .updateSelectedCategory(category);
                }
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
                        : AppColors.lightBorderAlt),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? AppColors.greyTextLight : AppColors.textDark),
                fontWeight: FontWeight.w700,
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemCount: categories.length,
        ),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, Gem gem, bool isDark) {
    final bool isCertified =
        gem.certificateUrl != null && gem.certificateUrl!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (gem.gemId != null) {
          context.push('/gem-details/${gem.gemId}', extra: gem);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorderAlt,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGemImage(gem, isDark),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              gem.name,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textDarkAlt,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionIcon(
                            Icons.edit,
                            onTap: () {
                              if (gem.gemId != null) {
                                context.push(
                                  '/gems/edit/${gem.gemId}',
                                  extra: gem,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildActionIcon(
                            Icons.delete_outline, 
                            onTap: () async {
                              if (gem.gemId == null) return;

                              // 1. Show Confirmation Dialog
                              final confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Gem Listing?'),
                                    content: Text('Are you sure you want to remove "${gem.name}" permanently from the market?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDelete != true || !context.mounted) return;

                              // 2. Perform the viewmodel logic sequence 
                              final success = await ref
                                  .read(gemMarketInventoryViewModelProvider.notifier)
                                  .deleteGem(gem.gemId!);

                              if (!context.mounted) return;

                              // 3. User Success Feedbacks Trigger
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: success ? AppColors.successGreen : AppColors.dangerRed,
                                  content: Text(
                                    success 
                                        ? 'Successfully deleted "${gem.name}"' 
                                        : 'Failed to delete "${gem.name}". Please try again.',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${gem.carat?.toStringAsFixed(2) ?? '0.00'} Carats',
                        style: const TextStyle(
                          color: AppColors.greyTextLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'LKR ${_formatPrice(gem.price ?? 0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildCertificationBadge(isCertified),
                          const SizedBox(width: 8),
                          _buildApprovalBadge(gem.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: AppColors.greyTextLight),
      ),
    );
  }

  Widget _buildGemImage(Gem gem, bool isDark) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
      child: Container(
        width: 132,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkBackgroundAlt
              : AppColors.lightBackgroundGrey,
          image: gem.imageUrl != null && gem.imageUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(gem.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: gem.imageUrl != null && gem.imageUrl!.isNotEmpty
            ? null
            : _placeholderImage(isDark),
      ),
    );
  }

  Widget _placeholderImage(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 32,
            color: isDark
                ? AppColors.greyTextLight
                : AppColors.greyTextSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            'img',
            style: TextStyle(
              color: isDark
                  ? AppColors.greyTextLight
                  : AppColors.greyTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationBadge(bool isCertified) {
    final Color bgColor = isCertified
        ? AppColors.accentGreenLight
        : AppColors.lightBackgroundGrey;
    final Color textColor = isCertified
        ? AppColors.primaryGreen
        : AppColors.textDarkAlt;
    final String label = isCertified ? 'CERTIFIED' : 'NOT CERTIFIED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCertified ? AppColors.primaryGreen : AppColors.greyTextLight,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildApprovalBadge(GemStatus status) {
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case GemStatus.APPROVED:
        bgColor = AppColors.accentGreenLight;
        textColor = AppColors.primaryGreen;
        label = 'APPROVED';
        break;
      case GemStatus.PENDING:
        bgColor = AppColors.lightBackgroundGrey;
        textColor = AppColors.accentOrange;
        label = 'PENDING';
        break;
      case GemStatus.REJECTED:
        bgColor = AppColors.redPale;
        textColor = AppColors.accentRed;
        label = 'REJECTED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status == GemStatus.APPROVED
              ? AppColors.primaryGreen
              : status == GemStatus.REJECTED
                  ? AppColors.accentRed
                  : AppColors.greyTextLight,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // Full representation with standard comma separations
  String _formatPrice(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  // Compressed values mapping cleanly inside tight subtext boundaries
  String _formatCompactPrice(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}
import 'package:flutter/material.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/features/gem_market/view/screens/certificate_view_screen.dart';
import 'package:gemhub/core/constants/app_colors.dart';

// Helper for price formatting in GemTitleSection
String _formatPrice(double? v) {
  if (v == null) return '0.00';
  return v
      .toStringAsFixed(2)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?=\.))'),
        (m) => '${m[1]},',
      );
}

// 1. GemOwnerActionTab
class GemOwnerActionTab extends StatelessWidget {
  final Gem gem;
  const GemOwnerActionTab({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppColors.primaryGreen,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Verified Seller',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : AppColors.darkBackground,
              foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'View Profile',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. GemTitleSection
class GemTitleSection extends StatelessWidget {
  final Gem gem;

  const GemTitleSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  gem.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.darkBackground,
                    letterSpacing: -0.6,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LKR ${_formatPrice(gem.price)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (gem.carat != null)
                    Text(
                      '${gem.carat} CARATS',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. GemSellerSection
class GemSellerSection extends StatelessWidget {
  final Gem gem;
  const GemSellerSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: AppColors.primaryGreen,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Authorized Dealer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : AppColors.darkBackground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primaryGreen,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Certified Marketplace Partner',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: isDark ? AppColors.greyText : AppColors.greyText),
          ],
        ),
      ),
    );
  }
}

// 4. GemSpecificationsSection
class GemSpecificationsSection extends StatelessWidget {
  final Gem gem;

  const GemSpecificationsSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final specs = [
      {'label': 'VARIETY', 'value': gem.variety ?? 'N/A'},
      {'label': 'COLOR', 'value': gem.color ?? 'N/A'},
      {'label': 'WEIGHT', 'value': '${gem.carat ?? 0} Carats'},
      {
        'label': 'CERTIFICATE',
        'value': gem.certificateUrl != null ? 'Available' : 'No Certificate',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.darkBackground,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: specs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) => _buildSpecBox(
              context,
              specs[i]['label']!,
              specs[i]['value']!,
              isDark,
              isLink: specs[i]['label'] == 'CERTIFICATE' &&
                  gem.certificateUrl != null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBox(
    BuildContext context,
    String label,
    String value,
    bool isDark, {
    bool isLink = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: isLink
            ? AppColors.primaryGreen.withOpacity(0.1)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLink
              ? AppColors.primaryGreen.withOpacity(0.3)
              : (isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder),
        ),
        boxShadow: [
          if (!isLink)
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.1 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: InkWell(
        onTap: isLink && gem.certificateUrl != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CertificateViewScreen(
                      url: gem.certificateUrl!,
                      gemName: gem.name,
                    ),
                  ),
                );
              }
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.greyTextLight : AppColors.greyText,
                    letterSpacing: 0.6,
                  ),
                ),
                if (isLink) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 10,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isLink
                    ? AppColors.primaryGreen
                    : (isDark ? Colors.white : AppColors.darkBackground),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// 5. GemDescriptionSection
class GemDescriptionSection extends StatelessWidget {
  final Gem gem;

  const GemDescriptionSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.darkBackground,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            gem.description != null && gem.description!.isNotEmpty
                ? gem.description!
                : 'No description provided.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.greyTextLight : AppColors.greyText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// 6. GemLocationSection
class GemLocationSection extends StatelessWidget {
  final Gem gem;
  const GemLocationSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.darkBackground,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.blueSky,
                border: Border.all(
                  color: isDark
                      ? AppColors.darkSurfaceAlt
                      : AppColors.lightBorder,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    'https://maps.googleapis.com/maps/api/staticmap?center=Mayfair,London&zoom=14&size=600x300&style=feature:all|saturation:-30&key=DEMO',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.bluePale,
                      child: const Center(
                        child: Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primaryGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              gem.location != null && gem.location!.isNotEmpty
                                  ? gem.location!
                                  : 'Location Not Specified',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.darkBackground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

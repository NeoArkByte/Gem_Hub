import 'package:flutter/material.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';

// Shared styling tokens for the detail screen components
class GemDetailTheme {
  static const bgSection = Color(0xFFF9FAFB);
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF2563EB);
  static const accentLight = Color(0xFFEFF6FF);
  static const text = Color(0xFF111827);
  static const subText = Color(0xFF6B7280);
  static const sectionDivider = Color(0xFFE5E7EB);

  static String formatPrice(double v) => v.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?=\.))'),
        (m) => '${m[1]},',
      );
}

// ─── App Bar & Carousel ───────────────────────────────────────────────────
class GemDetailAppBar extends StatelessWidget {
  final Gem gem;
  final List<String> images;
  final int currentImage;
  final ValueChanged<int> onPageChanged;

  const GemDetailAppBar({
    super.key,
    required this.gem,
    required this.images,
    required this.currentImage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: GemDetailTheme.text,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _circleBtn(
          Icons.arrow_back_ios_new_rounded,
          GemDetailTheme.text,
          () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _circleBtn(Icons.share_outlined, GemDetailTheme.text, () {}),
        ),
      ],
      title: Text(
        '${gem.type.displayName} Details',
        style: const TextStyle(
          color: GemDetailTheme.text,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: GemDetailTheme.accentLight,
                  child: const Center(
                    child: Icon(Icons.diamond, size: 72, color: GemDetailTheme.accent),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentImage == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: currentImage == i ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: kToolbarHeight + 8,
              right: 56,
              child: _circleBtn(Icons.zoom_in_rounded, Colors.white54, () {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─── Title Section ────────────────────────────────────────────────────────
class GemTitleSection extends StatelessWidget {
  final Gem gem;

  const GemTitleSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${gem.carat} Carat ${gem.name.isNotEmpty ? gem.name : gem.type.displayName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: GemDetailTheme.text,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GemDetailTheme.accentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GemDetailTheme.accent.withOpacity(0.3)),
                ),
                child: Text(
                  gem.status.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: GemDetailTheme.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${GemDetailTheme.formatPrice(gem.price)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: GemDetailTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Seller Section ───────────────────────────────────────────────────────
class GemSellerSection extends StatelessWidget {
  final Gem gem;
  const GemSellerSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: GemDetailTheme.accentLight,
                child: Icon(Icons.store, color: GemDetailTheme.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Seller ID: ${gem.ownerId.isNotEmpty ? gem.ownerId : "Unknown"}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: GemDetailTheme.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: GemDetailTheme.accent, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Contact: ${gem.sellerPhone.isNotEmpty ? gem.sellerPhone : "Not Provided"}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: GemDetailTheme.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: GemDetailTheme.text,
                side: const BorderSide(color: GemDetailTheme.border, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: GemDetailTheme.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Specifications Section ───────────────────────────────────────────────
class GemSpecificationsSection extends StatelessWidget {
  final Gem gem;

  const GemSpecificationsSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    final specs = [
      {'label': 'TYPE', 'value': gem.type.displayName},
      {'label': 'SHAPE', 'value': gem.shape.isNotEmpty ? gem.shape : 'N/A'},
      {'label': 'WEIGHT', 'value': '${gem.carat} Carats'},
      {'label': 'COLOR GRADE', 'value': gem.color.isNotEmpty ? gem.color : 'N/A'},
      {'label': 'CLARITY', 'value': gem.clarity.isNotEmpty ? gem.clarity : 'N/A'},
      {'label': 'TREATMENT', 'value': gem.treatment.isNotEmpty ? gem.treatment : 'N/A'},
      {'label': 'ORIGIN', 'value': gem.origin.isNotEmpty ? gem.origin : 'N/A'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GemDetailTheme.text,
            ),
          ),
          const SizedBox(height: 14),
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
            itemBuilder: (_, i) => _buildSpecBox(specs[i]['label']!, specs[i]['value']!),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: GemDetailTheme.bgSection,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GemDetailTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: GemDetailTheme.subText,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: GemDetailTheme.text,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Description Section ──────────────────────────────────────────────────
class GemDescriptionSection extends StatelessWidget {
  final Gem gem;

  const GemDescriptionSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GemDetailTheme.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            gem.description.isNotEmpty ? gem.description : 'No description provided.',
            style: const TextStyle(fontSize: 14, color: GemDetailTheme.subText, height: 1.6),
          ),
          if (gem.createdAt != null && gem.createdAt!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Listed on: ${_formatDate(gem.createdAt!)}',
              style: const TextStyle(fontSize: 12, color: GemDetailTheme.subText, fontStyle: FontStyle.italic),
            ),
          ],
          if (gem.videoUrl != null && gem.videoUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {}, // Handle video playback
                style: ElevatedButton.styleFrom(
                  backgroundColor: GemDetailTheme.accentLight,
                  foregroundColor: GemDetailTheme.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                label: const Text('Watch 360° Video', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final d = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (e) {
      return isoDate.split('T').first; // Fallback to YYYY-MM-DD
    }
  }
}

// ─── Location Section ─────────────────────────────────────────────────────
class GemLocationSection extends StatelessWidget {
  final Gem gem;
  const GemLocationSection({super.key, required this.gem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GemDetailTheme.text,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                border: Border.all(color: GemDetailTheme.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  Image.network(
                    'https://maps.googleapis.com/maps/api/staticmap?center=Mayfair,London&zoom=14&size=600x300&style=feature:all|saturation:-30&key=DEMO',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE5EEFF),
                      child: const Center(
                        child: Icon(Icons.map_outlined, size: 48, color: GemDetailTheme.accent),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: GemDetailTheme.accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            gem.location.isNotEmpty ? gem.location : 'Location Not Specified',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: GemDetailTheme.text,
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

// ─── Bottom Action Bar ────────────────────────────────────────────────────
class GemBottomActionBar extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onFavouriteToggle;

  const GemBottomActionBar({
    super.key,
    required this.isFavourite,
    required this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: GemDetailTheme.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onFavouriteToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isFavourite ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFavourite ? Colors.red : GemDetailTheme.subText,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: GemDetailTheme.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text(
                'Contact Seller',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

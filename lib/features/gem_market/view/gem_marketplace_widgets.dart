import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Light theme tokens ────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFFFFFFF);
  static const bgSection = Color(0xFFF9FAFB);
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF2563EB);
  static const accentLight = Color(0xFFEFF6FF);
  static const text = Color(0xFF111827);
  static const subText = Color(0xFF6B7280);
  static const sectionDivider = Color(0xFFE5E7EB);
}

// ─── Gem Data Model ────────────────────────────────────────────────────────────
class GemListing {
  final String name;
  final String carats;
  final String type;
  final double price;
  final bool isCertified;
  final String sellerName;
  final String sellerSubtitle;
  final double sellerRating;
  final int sellerReviews;
  final String weight;
  final String colorGrade;
  final String clarity;
  final String treatment;
  final String origin;
  final String shape;
  final String description;
  final String location;
  final String imageUrl;

  const GemListing({
    required this.name,
    required this.carats,
    required this.type,
    required this.price,
    required this.isCertified,
    required this.sellerName,
    required this.sellerSubtitle,
    required this.sellerRating,
    required this.sellerReviews,
    required this.weight,
    required this.colorGrade,
    required this.clarity,
    required this.treatment,
    required this.origin,
    required this.shape,
    required this.description,
    required this.location,
    required this.imageUrl,
  });
}

// ─── Demo data ────────────────────────────────────────────────────────────────
const _demo = GemListing(
  name: 'Royal Blue Sapphire',
  carats: '6.5 Carat',
  type: 'Royal Blue Sapphire',
  price: 14500.00,
  isCertified: true,
  sellerName: 'Gemstone Collective',
  sellerSubtitle: 'Top Rated Dealer • London, UK',
  sellerRating: 4.9,
  sellerReviews: 98,
  weight: '6.52 Carats',
  colorGrade: 'Royal Blue',
  clarity: 'Eye Clean (VVS)',
  treatment: 'No Heat',
  origin: 'Ceylon (Sri Lanka)',
  shape: 'Cushion Cut',
  description:
      'This exceptional 6.52 carat Royal Blue Sapphire hails from the legendary mines of Ceylon. '
      'Boasting an intense, velvety blue hue that maintains its saturation even in low light, this '
      'cushion-cut masterpiece represents the pinnacle of gemstone quality. Completely natural with '
      'no evidence of heat treatment, it comes with a GRS certification verifying its origin and quality.',
  location: 'Mayfair, London, UK',
  imageUrl:
      'https://images.unsplash.com/photo-1601121141461-9d6647bef0a1?w=700',
);

// ─── Main Screen ──────────────────────────────────────────────────────────────
class ListingDetailScreen extends StatefulWidget {
  final GemListing listing;

  const ListingDetailScreen({super.key, this.listing = _demo});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isFavourite = false;
  int _currentImage = 0;

  final List<String> _images = [
    'https://images.unsplash.com/photo-1601121141461-9d6647bef0a1?w=700',
    'https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=700',
    'https://images.unsplash.com/photo-1615751072497-5f5169febe17?w=700',
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final gem = widget.listing;

    return Scaffold(
      backgroundColor: _T.bg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Scrollable content ──
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(gem),
                    _buildDivider(),
                    _buildSellerSection(gem),
                    _buildDivider(),
                    _buildSpecificationsSection(gem),
                    _buildDivider(),
                    _buildDescriptionSection(gem),
                    _buildDivider(),
                    _buildLocationSection(gem),
                    const SizedBox(height: 100), // space for bottom bar
                  ],
                ),
              ),
            ],
          ),
          // ── Sticky bottom bar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  // ─── App Bar / Image Carousel ─────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: _T.bg,
      elevation: 0,
      foregroundColor: _T.text,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _circleBtn(
          Icons.arrow_back_ios_new_rounded,
          _T.text,
          () => Navigator.maybePop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: _circleBtn(
            Icons.share_outlined,
            _T.text,
            () {},
          ),
        ),
      ],
      title: const Text(
        'Blue Sapphire Details',
        style: TextStyle(
          color: _T.text,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Page view
            PageView.builder(
              itemCount: _images.length,
              onPageChanged: (i) => setState(() => _currentImage = i),
              itemBuilder: (_, i) => Image.network(
                _images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _T.accentLight,
                  child: const Center(
                    child: Icon(Icons.diamond, size: 72, color: _T.accent),
                  ),
                ),
              ),
            ),
            // Dot indicators
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _currentImage == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _currentImage == i
                          ? Colors.white
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            // Small top-right zoom icon
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

  // ─── Title Section ────────────────────────────────────────────────────────
  Widget _buildTitleSection(GemListing gem) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with CERTIFIED badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '${gem.carats} ${gem.type}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _T.text,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (gem.isCertified)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _T.accentLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _T.accent.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'CERTIFIED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _T.accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Price
          Text(
            '\$${_fmt(gem.price)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _T.accent,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Seller Section ───────────────────────────────────────────────────────
  Widget _buildSellerSection(GemListing gem) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              // Seller avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: _T.accentLight,
                child: const Icon(Icons.store, color: _T.accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          gem.sellerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _T.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: _T.accent,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      gem.sellerSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _T.subText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // View Profile button — full width outlined
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _T.text,
                side: const BorderSide(color: _T.border, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _T.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Specifications ───────────────────────────────────────────────────────
  Widget _buildSpecificationsSection(GemListing gem) {
    final specs = [
      _SpecItem('WEIGHT', gem.weight),
      _SpecItem('COLOR GRADE', gem.colorGrade),
      _SpecItem('CLARITY', gem.clarity),
      _SpecItem('TREATMENT', gem.treatment),
      _SpecItem('ORIGIN', gem.origin),
      _SpecItem('SHAPE', gem.shape),
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
              color: _T.text,
            ),
          ),
          const SizedBox(height: 14),
          // 2-column grid of spec boxes
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
            itemBuilder: (_, i) => _buildSpecBox(specs[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecBox(_SpecItem spec) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: _T.bgSection,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            spec.label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: _T.subText,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            spec.value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _T.text,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Description ─────────────────────────────────────────────────────────
  Widget _buildDescriptionSection(GemListing gem) {
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
              color: _T.text,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            gem.description,
            style: const TextStyle(
              fontSize: 14,
              color: _T.subText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Location ─────────────────────────────────────────────────────────────
  Widget _buildLocationSection(GemListing gem) {
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
              color: _T.text,
            ),
          ),
          const SizedBox(height: 12),
          // Map placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                border: Border.all(color: _T.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  // Map tile placeholder
                  Image.network(
                    'https://maps.googleapis.com/maps/api/staticmap?center=Mayfair,London&zoom=14&size=600x300&style=feature:all|saturation:-30&key=DEMO',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE5EEFF),
                      child: const Center(
                        child: Icon(Icons.map_outlined, size: 48, color: _T.accent),
                      ),
                    ),
                  ),
                  // Location pin overlay
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
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
                            color: _T.accent,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gem.location,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _T.text,
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

  // ─── Divider ──────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return const Divider(
      color: _T.sectionDivider,
      thickness: 1,
      height: 1,
    );
  }

  // ─── Bottom Action Bar ────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: _T.border),
        ),
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
          // Favourite button
          GestureDetector(
            onTap: () => setState(() => _isFavourite = !_isFavourite),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isFavourite
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavourite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavourite ? Colors.red : _T.subText,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contact Seller button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.accent,
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?=\.))'),
        (m) => '${m[1]},',
      );
}

// ─── Helper ───────────────────────────────────────────────────────────────────
class _SpecItem {
  final String label;
  final String value;
  const _SpecItem(this.label, this.value);
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/features/gem_market/view/components/gem_detail_components.dart';

class ListingDetailScreen extends StatefulWidget {
  final Gem gem;

  const ListingDetailScreen({super.key, required this.gem});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isFavourite = false;
  int _currentImage = 0;

  late final List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = widget.gem.imageUrl != null && widget.gem.imageUrl!.isNotEmpty
        ? [widget.gem.imageUrl!]
        : [];
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Scrollable content ──
          CustomScrollView(
            slivers: [
              GemDetailAppBar(
                gem: widget.gem,
                images: _images,
                currentImage: _currentImage,
                onPageChanged: (i) => setState(() => _currentImage = i),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GemOwnerActionTab(gem: widget.gem),
                    GemTitleSection(gem: widget.gem),
                    GemSellerSection(gem: widget.gem),
                    GemSpecificationsSection(gem: widget.gem),
                    GemDescriptionSection(gem: widget.gem),
                    GemLocationSection(gem: widget.gem),
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
            child: GemBottomActionBar(
              isFavourite: _isFavourite,
              onFavouriteToggle: () => setState(() => _isFavourite = !_isFavourite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: GemDetailTheme.sectionDivider,
      thickness: 1,
      height: 1,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/features/gem_market/view/components/gem_detail_components.dart';
import 'package:job_market/core/constants/app_colors.dart';

class GemListingDetailScreen extends StatefulWidget {
  final Gem gem;

  const GemListingDetailScreen({super.key, required this.gem});

  @override
  State<GemListingDetailScreen> createState() => _GemListingDetailScreenState();
}

class _GemListingDetailScreenState extends State<GemListingDetailScreen> {
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          
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

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GemBottomActionBar(
              isFavourite: _isFavourite,
              onFavouriteToggle: () =>
                  setState(() => _isFavourite = !_isFavourite),
            ),
          ),
        ],
      ),
    );
  }

}

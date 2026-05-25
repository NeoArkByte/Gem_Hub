import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:gemhub/features/jobs/viewmodels/marketplace_viewmodel.dart'; // marketplaceViewModelProvider තියෙන තැන
import 'package:gemhub/features/jobs/view/widgets/post_job_components.dart'; // PostJobLocationPicker එක තියෙන තැන
import 'package:gemhub/features/jobs/viewmodels/marketplace_viewmodel.dart'; // marketplaceViewModelProvider තියෙන තැන

class MarketplaceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;

  const MarketplaceSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onSearchChanged,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey[400]),
                  hintText: 'Search jobs...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF10C971),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.tune, color: Colors.white),
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const JobFilterBottomSheet(),
  );
}


class JobFilterBottomSheet extends ConsumerStatefulWidget {
  const JobFilterBottomSheet({super.key});

  @override
  ConsumerState<JobFilterBottomSheet> createState() =>
      _JobFilterBottomSheetState();
}

class _JobFilterBottomSheetState extends ConsumerState<JobFilterBottomSheet> {
  final Color primaryGreen = const Color(0xFF10C971);

  
  late String _selectedCategory;
  late String _selectedLocation;
  late RangeValues _salaryRange;

  final List<String> _categories = [
    'All Jobs',
    'Gem Cutter',
    'Polisher',
    'Gemologist',
    'Jewelry Designer',
    'Bench Jeweler',
    'Sales Executive',
  ];

  @override
  void initState() {
    super.initState();

    final viewModel = ref.read(marketplaceViewModelProvider.notifier);

    
    _selectedCategory = viewModel.currentCategory.isEmpty
        ? 'All Jobs'
        : viewModel.currentCategory;

    
    _selectedLocation = viewModel.currentLocation.isEmpty
        ? 'All Locations'
        : viewModel.currentLocation;

    _salaryRange = RangeValues(
      viewModel.currentMinSalary,
      viewModel.currentMaxSalary,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        ref
                            .read(marketplaceViewModelProvider.notifier)
                            .clearFilters();

                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// CATEGORY
            Text(
              'Job Category',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: isDark
                      ? const Color(0xFF1F2937)
                      : Colors.white,
                  style: TextStyle(color: textColor, fontSize: 16),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 8),

            PostJobLocationPicker(
              onPlaceSelected: (String place) {
                setState(() {
                  _selectedLocation = place.split(',').first.trim();
                });
              },
            ),

            if (_selectedLocation != 'All Locations') ...[
              const SizedBox(height: 8),
              Text(
                'Selected: $_selectedLocation',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            const SizedBox(height: 24),

            /// SALARY
            Text(
              'Monthly Salary (LKR)',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LKR ${_salaryRange.start.round()}',
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'LKR ${_salaryRange.end.round()}',
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _salaryRange,
              min: 0,
              max: 300000,
              divisions: 30,
              activeColor: primaryGreen,
              inactiveColor: primaryGreen.withOpacity(0.2),
              labels: RangeLabels(
                'LKR ${_salaryRange.start.round()}',
                'LKR ${_salaryRange.end.round()}',
              ),
              onChanged: (values) {
                setState(() {
                  _salaryRange = values;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(marketplaceViewModelProvider.notifier)
                      .updateFilters(
                        category: _selectedCategory == 'All Jobs'
                            ? ''
                            : _selectedCategory,
                        location: _selectedLocation == 'All Locations'
                            ? ''
                            : _selectedLocation,
                        minSalary: _salaryRange.start,
                        maxSalary: _salaryRange.end,
                      );

                  Navigator.pop(context); // Bottom Sheet එක වහනවා
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ], 
        ),
      ),
    );
  }
}

class MarketplaceCategories extends StatefulWidget {
  final Function(String) onCategorySelected;

  const MarketplaceCategories({super.key, required this.onCategorySelected});

  @override
  State<MarketplaceCategories> createState() => _MarketplaceCategoriesState();
}

class _MarketplaceCategoriesState extends State<MarketplaceCategories> {
  String _selectedCategory = 'All Jobs';

  final List<String> categories = [
    'All Jobs',
    'Gem Cutter',
    'Polisher',
    'Gemologist',
    'Jewelry Designer',
    'Bench Jeweler',
    'Sales Executive',
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: categories.map((cat) {
            bool isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                  });
                  widget.onCategorySelected(cat);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF10C971)
                        : (isDark ? const Color(0xFF1F2937) : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? const Color(0xFF374151)
                                : Colors.grey.withOpacity(0.3),
                          ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          if (actionText != null)
            Text(
              actionText!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10C971),
              ),
            ),
          if (icon != null)
            Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ],
      ),
    );
  }
}

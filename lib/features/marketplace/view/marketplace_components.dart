import 'package:flutter/material.dart';

// 👇 1. SEARCH BAR EKA DYNAMIC KALA
class MarketplaceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;

  const MarketplaceSearchBar({
    Key? key, 
    required this.controller, 
    required this.onSearchChanged
  }) : super(key: key);

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
                controller: controller, // 👈 Controller eka link kala
                onChanged: onSearchChanged, // 👈 Type karaddi weda
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  icon: Icon(
                    Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey[400],
                  ),
                  hintText: 'Search job titles or companies',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF10C971),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// 👇 2. CATEGORIES TIKA DYNAMIC KALA (StatefulWidget kara)
class MarketplaceCategories extends StatefulWidget {
  final Function(String) onCategorySelected;

  const MarketplaceCategories({
    Key? key, 
    required this.onCategorySelected
  }) : super(key: key);

  @override
  State<MarketplaceCategories> createState() => _MarketplaceCategoriesState();
}

class _MarketplaceCategoriesState extends State<MarketplaceCategories> {
  // Danata select wela thiyena eka methana save wenawa
  String _selectedCategory = 'All Jobs'; 
  
  // 👇 ALUTH CATEGORIES TIKA METHANATA DAMMA
  final List<String> categories = [
    'All Jobs', 
    'Gem Cutter', 
    'Polisher', 
    'Gemologist', 
    'Jewelry Designer',
    'Bench Jeweler',
    'Sales Executive'
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
            bool isSelected = _selectedCategory == cat; // 👈 Dynamic Check eka
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = cat; // Click kalama state eka maru wenawa
                  });
                  widget.onCategorySelected(cat); // Parent screen ekata kiyanawa
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

// (SectionHeader eka wenas une na)
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final IconData? icon;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionText,
    this.icon,
  }) : super(key: key);

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

// 👇 3. BOTTOM NAV EKA DYNAMIC KALA
class MarketplaceBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MarketplaceBottomNav({
    Key? key, 
    required this.currentIndex, 
    required this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? const Color(0xFF111827) : Colors.white, 
      selectedItemColor: const Color(0xFF10C971),
      unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      currentIndex: currentIndex, // 👈 Hardcoded '3' wenuwata meka damma
      onTap: onTap, // 👈 Click karaddi wena function eka link kala
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.diamond_outlined), label: 'Inventory'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Market'),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}
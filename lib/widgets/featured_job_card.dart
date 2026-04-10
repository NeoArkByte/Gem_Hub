import 'package:flutter/material.dart';

class FeaturedJobCard extends StatelessWidget {
  final String title;
  final String company;
  final String salary;
  final String timePosted;
  final bool isPremium;
  final Color logoColor;

  const FeaturedJobCard({
    Key? key,
    required this.title,
    required this.company,
    required this.salary,
    required this.timePosted,
    required this.isPremium,
    required this.logoColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 👇 Dark mode check
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1F2937)
            : Colors.white, // Dynamic Background
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF374151)
                      : Colors.grey[100], // Logo Background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(width: 32, height: 32, color: logoColor),
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3B2C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Just Now Listed',
                    style: TextStyle(
                      color: Color(0xFF10C971),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ), // Text Color
          const SizedBox(height: 4),
          Text(
            company,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                salary,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10C971),
                ),
              ),
              Text(
                timePosted,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

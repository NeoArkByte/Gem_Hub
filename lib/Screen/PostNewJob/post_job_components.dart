import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- 1. HERO SECTION ---
class PostJobHeroSection extends StatelessWidget {
  final Color textColor;
  const PostJobHeroSection({Key? key, required this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hire an Expert',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Reach thousands of verified gemstone professionals\nand industry masters.',
          style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
        ),
      ],
    );
  }
}

// --- 2. SECTION HEADER ---
class PostJobSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color primaryYellow;

  const PostJobSectionHeader({
    Key? key,
    required this.icon,
    required this.title,
    required this.primaryYellow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: primaryYellow, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: primaryYellow,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// --- 3. CUSTOM TEXT FIELD ---
class PostJobTextField extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;
  final IconData? prefixIcon;
  final TextEditingController? controller;

  const PostJobTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.prefixIcon,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    Color borderColor = isDark ? const Color(0xFF374151) : Colors.grey[300]!;
    Color labelColor = isDark ? Colors.grey[300]! : const Color(0xFF1F2937);
    Color inputColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: labelColor),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(fontSize: 16, color: inputColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: maxLines > 1 ? 16 : 18,
              ),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey[400], size: 22) : null,
            ),
          ),
        ),
      ],
    );
  }
}

// --- 4. SKILLS SECTION ---
class PostJobSkills extends StatelessWidget {
  final Color primaryYellow;
  const PostJobSkills({Key? key, required this.primaryYellow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color labelColor = isDark ? Colors.grey[300]! : const Color(0xFF1F2937);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Required',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: labelColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSkillChip('Faceting', true, isDark),
            _buildSkillChip('Gemology', true, isDark),
            _buildSkillChip('+ Add Skill', false, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(String text, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? primaryYellow.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? primaryYellow.withOpacity(0.3) : (isDark ? Colors.grey[700]! : Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? const Color(0xFFD97706) : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            const Icon(Icons.close, size: 14, color: Color(0xFFD97706)),
          ],
        ],
      ),
    );
  }
}

// --- 5. BOTTOM ACTION BUTTON ---
class PostJobBottomAction extends StatelessWidget {
  final VoidCallback onPublish;
  final Color bgColor;
  final Color primaryYellow;

  const PostJobBottomAction({
    Key? key,
    required this.onPublish,
    required this.bgColor,
    required this.primaryYellow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF374151) : Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: onPublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryYellow,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.send, size: 20),
                SizedBox(width: 10),
                Text('Publish Job Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'STANDARD LISTING FEE: \$49.00',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.0),
          ),
        ],
      ),
    );
  }
}

// --- 6. OPEN STREET MAP (OSM) LOCATION PICKER ---
class PostJobLocationPicker extends StatefulWidget {
  final Function(String) onPlaceSelected;

  const PostJobLocationPicker({
    Key? key,
    required this.onPlaceSelected,
  }) : super(key: key);

  @override
  State<PostJobLocationPicker> createState() => _PostJobLocationPickerState();
}

class _PostJobLocationPickerState extends State<PostJobLocationPicker> {
  
  // OSM API eken data ganna function eka (No API Key Required!)
  Future<List<String>> _searchPlaces(String query) async {
    if (query.isEmpty || query.length < 3) return []; // Akuru 3k wath type karama thama search wenne

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'GemCostJobsApp/1.0', // OSM requires a User-Agent to prevent blocking
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) => item['display_name'] as String).toList();
      }
    } catch (e) {
      print("OSM Error: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    Color borderColor = isDark ? const Color(0xFF374151) : Colors.grey[300]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : const Color(0xFF1F2937)),
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            // User type karana eka auto main variable ekata yanawa
            widget.onPlaceSelected(textEditingValue.text);
            return await _searchPlaces(textEditingValue.text);
          },
          onSelected: (String selection) {
            widget.onPlaceSelected(selection);
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search city or country...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.location_on, color: Colors.grey[400], size: 22),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(20),
                color: bgColor,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 48, // Padding eka adu karala width eka haduwa
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: borderColor),
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF10C971)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
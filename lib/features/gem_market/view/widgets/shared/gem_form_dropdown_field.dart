import 'package:flutter/material.dart';
import 'package:job_market/core/constants/app_colors.dart';

class GemFormDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? prefixIcon;
  final bool optional;

  const GemFormDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldBg = isDark ? AppColors.darkSurface : Colors.white;
    final Color labelColor = isDark ? Colors.grey[300]! : const Color(0xFF1F2937);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String variety) {
            return DropdownMenuItem<String>(
              value: variety,
              child: Text(
                variety,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: fieldBg,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[400], size: 18)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.primaryYellow,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
          validator: optional
              ? null
              : (value) => value == null ? 'Please select $label' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

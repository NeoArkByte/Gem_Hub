import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class InventoryFormDropdownField<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final bool optional;
  final String? Function(T?)? validator;

  const InventoryFormDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    required this.onChanged,
    this.prefixIcon,
    this.optional = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldBg = isDark ? AppColors.darkSurface : Colors.white;
    final Color labelColor =
        isDark ? Colors.grey[300]! : const Color(0xFF1F2937);

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
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
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
                color:
                    isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
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
          validator: validator ??
              (optional
                  ? null
                  : (value) => value == null ? 'Please select $label' : null),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

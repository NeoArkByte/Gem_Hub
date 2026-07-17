import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class InventoryFormTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final String? suffixText;
  final bool optional;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const InventoryFormTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.suffixText,
    this.optional = false,
    this.validator,
    this.focusNode,
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
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          focusNode: focusNode,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[400], size: 18)
                : null,
            suffixIcon: suffixIcon,
            suffixText: suffixText,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.dangerRed,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.dangerRed,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (!optional && (value == null || value.trim().isEmpty)) {
              return 'Please enter $label';
            }
            if (validator != null) {
              return validator!(value);
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

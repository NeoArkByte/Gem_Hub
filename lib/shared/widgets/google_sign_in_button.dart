import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_market/core/constants/app_colors.dart';

class GoogleSignInButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String label;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label = 'Sign in with Google',
  });

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.googleButtonDarkBackground
        : Colors.white;
    final borderColor = isDark
        ? AppColors.googleButtonDarkBorder
        : AppColors.googleButtonLightBorder;
    final textColor = isDark
        ? AppColors.googleButtonDarkText
        : AppColors.googleButtonLightText;
    final iconBoxColor = isDark
        ? AppColors.googleButtonDarkIconBox
        : Colors.white;
    final progressColor = AppColors.primaryGreen;

    return Container(
      width: double.infinity,
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handlePress,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: _isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: iconBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/google-icon.svg',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      placeholderBuilder: (context) => const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

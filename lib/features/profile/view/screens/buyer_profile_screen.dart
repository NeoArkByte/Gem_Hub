import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/auth/profile_model.dart';

class BuyerProfileScreen extends StatelessWidget {
  final ProfileUser profile;

  const BuyerProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color subColor = isDark ? AppColors.greyTextLight : AppColors.greyText;
    final Color dividerColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Buyer Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // 1. Header Profile Identity Card
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBackgroundGrey,
                        backgroundImage: profile.avatarUrl != null
                            ? NetworkImage('${profile.avatarUrl!}?t=${DateTime.now().millisecondsSinceEpoch}') as ImageProvider
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.username ?? "Verified Buyer",
                      style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.1),
                    ),
                    const SizedBox(height: 6),
                    
                    // Verified Buyer Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user_rounded, color: AppColors.primaryGreen, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            "VERIFIED BUYER",
                            style: TextStyle(
                              color: AppColors.primaryGreen, 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold, 
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 2. Overview Biography Segment
              if (profile.description!.isNotEmpty) ...[
                _buildSectionLabel("ABOUT BUYER"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Text(
                    profile.description!,
                    style: TextStyle(
                      color: textColor.withOpacity(0.85), 
                      fontSize: 13.5, 
                      height: 1.45, 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // 3. Buyer Detailed Contact Info Group
              _buildSectionLabel("ACCOUNT DETAILS"),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: dividerColor),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      label: "Email Address",
                      value: profile.email!.isNotEmpty ? profile.email! : "Not Provided",
                      icon: Icons.mail_outline_rounded,
                      iconColor: AppColors.primaryBlue,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                    Divider(height: 1, color: dividerColor),
                    _buildInfoTile(
                      label: "Telephone Number",
                      value: profile.phone!.isNotEmpty ? profile.phone! : "Not Provided",
                      icon: Icons.phone_android_rounded,
                      iconColor: AppColors.accentPurple,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 10, top: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.greyTextLight,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color subColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: subColor, fontSize: 11.5, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

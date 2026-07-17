import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final greyText = isDark ? Colors.grey[400]! : AppColors.greyText;
    final dividerColor =
        isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Terms & Privacy',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          labelColor: textColor,
          unselectedLabelColor: greyText,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Terms of Service'),
            Tab(text: 'Privacy Policy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTermsTab(cardColor, textColor, greyText, dividerColor),
          _buildPrivacyTab(cardColor, textColor, greyText, dividerColor),
        ],
      ),
    );
  }

  Widget _buildTermsTab(
      Color cardColor, Color textColor, Color greyText, Color dividerColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lastUpdated('January 1, 2025', greyText),
          const SizedBox(height: 16),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '1. Acceptance of Terms',
            content:
                'By accessing or using GemHub, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our service.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '2. Use of Service',
            content:
                'GemHub is a platform for buying, selling, and managing gemstones and job listings within the gem industry. You agree to use the platform only for lawful purposes and in accordance with these Terms.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '3. User Accounts',
            content:
                'You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized use of your account. GemHub is not liable for any losses caused by unauthorized use of your account.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '4. Gem Listings',
            content:
                'All gem listings must be accurate and truthful. GemHub reserves the right to remove any listing that violates our guidelines or is deemed fraudulent. Sellers are responsible for ensuring their listings comply with all applicable laws.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '5. Prohibited Activities',
            content:
                'Users may not engage in fraud, harassment, or any illegal activities on the platform. Misrepresentation of gem quality, origin, or value is strictly prohibited and may result in permanent account suspension.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '6. Intellectual Property',
            content:
                'All content on GemHub, including logos, design elements, and text, is the property of GemHub and is protected by copyright law. Users retain ownership of their own uploaded content.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '7. Limitation of Liability',
            content:
                'GemHub is provided "as is" without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages arising from your use of the service.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '8. Changes to Terms',
            content:
                'GemHub reserves the right to modify these Terms at any time. We will notify users of significant changes via email or in-app notification. Continued use of the service constitutes acceptance of the new Terms.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab(
      Color cardColor, Color textColor, Color greyText, Color dividerColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _lastUpdated('January 1, 2025', greyText),
          const SizedBox(height: 16),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '1. Information We Collect',
            content:
                'We collect information you provide directly, such as your name, email address, and profile details. We also collect usage data, device information, and transaction history to improve our services.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '2. How We Use Your Information',
            content:
                'Your information is used to provide and improve our services, process transactions, send important notifications, and personalize your experience. We do not sell your personal data to third parties.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '3. Data Storage & Security',
            content:
                'Your data is stored securely using Supabase\'s enterprise-grade infrastructure with industry-standard encryption. We regularly review and update our security practices to protect your information.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '4. Sharing of Information',
            content:
                'We may share your information with trusted service providers who assist us in operating the platform, subject to strict confidentiality agreements. We may also disclose information when required by law.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '5. Cookies & Tracking',
            content:
                'We use cookies and similar technologies to enhance your experience, analyze usage patterns, and provide personalized content. You can control cookie settings through your device settings.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '6. Your Rights',
            content:
                'You have the right to access, correct, or delete your personal data. You may also request a copy of your data or opt out of certain data processing activities by contacting our support team.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '7. Children\'s Privacy',
            content:
                'GemHub is not intended for users under the age of 18. We do not knowingly collect personal information from minors. If we become aware of such collection, we will take steps to delete the information.',
          ),
          _section(
            cardColor,
            textColor,
            dividerColor,
            title: '8. Contact Us',
            content:
                'If you have any questions about this Privacy Policy or our data practices, please contact us at privacy@gemhub.app.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _lastUpdated(String date, Color greyText) {
    return Row(
      children: [
        Icon(Icons.update, size: 14, color: greyText),
        const SizedBox(width: 6),
        Text(
          'Last updated: $date',
          style: TextStyle(
              color: greyText, fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _section(
    Color cardColor,
    Color textColor,
    Color dividerColor, {
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                color: textColor.withOpacity(0.75),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

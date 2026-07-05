import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
          'Help Center',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: greyText, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search help topics...',
                        hintStyle: TextStyle(color: greyText, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _sectionTitle('Getting Started', greyText),
            const SizedBox(height: 10),
            _faqCard(cardColor, textColor, dividerColor, [
              (
                'How do I create an account?',
                'Download the app and tap "Sign Up". Enter your email, create a password, and complete your profile to get started.'
              ),
              (
                'How do I list a gem for sale?',
                'Navigate to Gem Market → Inventory → Add New Gem. Fill in the details, upload photos, and submit for approval.'
              ),
              (
                'How do I apply for a job?',
                'Browse the Job Market tab, tap on a listing you like, and hit "Apply" to send your profile to the employer.'
              ),
            ]),
            const SizedBox(height: 22),
            _sectionTitle('Account & Billing', greyText),
            const SizedBox(height: 10),
            _faqCard(cardColor, textColor, dividerColor, [
              (
                'How do I update my profile?',
                'Go to Profile → Edit Personal Profile. You can change your username, description, and profile picture.'
              ),
              (
                'How do I reset my password?',
                'On the login screen, tap "Forgot Password" and enter your email. You\'ll receive a reset link shortly.'
              ),
              (
                'Is my data secure?',
                'Yes. We use industry-standard encryption and Supabase\'s secure infrastructure to protect your personal data.'
              ),
            ]),
            const SizedBox(height: 22),
            _sectionTitle('Gem Market', greyText),
            const SizedBox(height: 10),
            _faqCard(cardColor, textColor, dividerColor, [
              (
                'How long does gem approval take?',
                'Our team typically reviews gem listings within 24–48 hours. You\'ll receive a notification once approved.'
              ),
              (
                'Can I edit a gem listing?',
                'Yes! Go to Gem Market → Inventory, tap on the gem, and select "Edit".'
              ),
              (
                'Why was my gem rejected?',
                'Listings may be rejected if they violate our quality guidelines or contain incomplete information. Check the rejection reason in your notifications.'
              ),
            ]),
            const SizedBox(height: 22),
            _sectionTitle('Contact Us', greyText),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dividerColor),
              ),
              child: Column(
                children: [
                  _contactTile(Icons.email_outlined, 'Email Support',
                      'support@gemhub.app', textColor, greyText),
                  Divider(color: dividerColor, height: 1),
                  _contactTile(Icons.chat_bubble_outline, 'Live Chat',
                      'Available 9am – 6pm, Mon–Fri', textColor, greyText),
                  Divider(color: dividerColor, height: 1),
                  _contactTile(Icons.language, 'Visit our Website',
                      'www.gemhub.app/help', textColor, greyText),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _faqCard(Color cardColor, Color textColor, Color dividerColor,
      List<(String, String)> items) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _faqTile(item.$1, item.$2, textColor),
              if (i < items.length - 1) Divider(color: dividerColor, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _faqTile(String question, String answer, Color textColor) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      iconColor: AppColors.primaryGreen,
      title: Text(
        question,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Text(
          answer,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _contactTile(IconData icon, String title, String subtitle,
      Color textColor, Color greyText) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: greyText, fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: greyText),
    );
  }
}

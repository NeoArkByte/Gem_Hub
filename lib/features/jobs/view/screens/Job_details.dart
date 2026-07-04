import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';

class JobDetailsScreen extends ConsumerWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  final Color primaryGreen = const Color(0xFF10C971);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF111827) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    Color greyText = isDark ? Colors.grey[400]! : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Job Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
        //         shape: BoxShape.circle,
        //       ),
        //       child: IconButton(
        //         icon: Icon(Icons.ios_share, size: 20, color: textColor),
        //         onPressed: () {},
        //       ),
        //     ),
        //   ),
        //   const SizedBox(width: 8),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(textColor, greyText, isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildTagsRow(isDark),
                  const SizedBox(height: 32),
                  _buildAboutSection(textColor, greyText),
                  const SizedBox(height: 24),
                  _buildSalaryCard(textColor, greyText, isDark),
                  const SizedBox(height: 32),
                  _buildSafetyTipsSection(isDark),
                  const SizedBox(height: 32),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionArea(context, ref, isDark),
    );
  }

  Widget _buildHeaderSection(Color textColor, Color greyText, bool isDark) {
    List<String> companyParts = (job.companyInfo ?? '').split(' • ');
    String companyName =
        companyParts.isNotEmpty ? companyParts[0] : 'Unknown Employer';
    String location = companyParts.length > 1 ? companyParts[1] : 'Sri Lanka';

    String formattedDate = 'Recently';
    if (job.createdAt != null) {
      try {
        DateTime parsedDate = DateTime.parse(
          job.createdAt!,
        ).toLocal();
        List<String> months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        String period = parsedDate.hour >= 12 ? 'pm' : 'am';
        int hour = parsedDate.hour > 12
            ? parsedDate.hour - 12
            : (parsedDate.hour == 0 ? 12 : parsedDate.hour);
        String minute = parsedDate.minute.toString().padLeft(2, '0');

        formattedDate =
            "${parsedDate.day} ${months[parsedDate.month - 1]} $hour:$minute $period";
      } catch (e) {
        formattedDate = job.createdAt!;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryGreen.withOpacity(0.15),
            isDark ? const Color(0xFF111827) : Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title ?? 'Job Title',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: greyText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Posted on $formattedDate',
                  style: TextStyle(fontSize: 14, color: greyText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: greyText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(fontSize: 14, color: greyText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business_center_outlined, size: 16, color: greyText),
              const SizedBox(width: 8),
              Text(
                'Posted by ',
                style: TextStyle(fontSize: 14, color: greyText),
              ),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.verified, color: primaryGreen, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(bool isDark) {
    List<String> tagsList =
        (job.tags).split(',').where((t) => t.trim().isNotEmpty).toList();

    if (tagsList.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: tagsList.map((tag) {
        return _buildTag(
          Icons.star_border_rounded,
          tag.trim(),
          isDark ? const Color(0xFF1F2937) : primaryGreen.withOpacity(0.1),
          isDark ? Colors.grey[300]! : primaryGreen,
        );
      }).toList(),
    );
  }

  Widget _buildTag(
    IconData icon,
    String text,
    Color bgColor,
    Color tagTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tagTextColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: tagTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Color textColor, Color greyText) {
    String descriptionText =
        (job.description != null && job.description!.trim().isNotEmpty)
            ? job.description!
            : 'No detailed description provided for this job.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Role',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          descriptionText,
          style: TextStyle(fontSize: 15, color: greyText, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSalaryCard(Color textColor, Color greyText, bool isDark) {
    String salaryDisplay = 'Negotiable';

    if (job.minSalary != null && job.maxSalary != null) {
      salaryDisplay =
          'LKR ${job.minSalary!.toStringAsFixed(0)} - ${job.maxSalary!.toStringAsFixed(0)}';
    } else if (job.minSalary != null) {
      salaryDisplay = 'LKR ${job.minSalary!.toStringAsFixed(0)}';
    } else if (job.maxSalary != null) {
      salaryDisplay = 'LKR ${job.maxSalary!.toStringAsFixed(0)}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : Colors.grey[200]!,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OFFERED SALARY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: greyText,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  salaryDisplay,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: primaryGreen,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyTipsSection(bool isDark) {
    Color warningBg =
        isDark ? const Color(0xFF3F1919) : const Color(0xFFFEF2F2);
    Color warningBorder =
        isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
    Color warningIcon =
        isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444);
    Color warningText =
        isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: warningBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gpp_maybe_outlined, color: warningIcon, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stay Alert: Avoid Online Scams',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: warningText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Gem Hub support will never ask for your passwords or message you directly. Don’t click unknown links, share OTPs/card details, or pay any upfront fees to employers. Always verify the job first.',
            style: TextStyle(
              fontSize: 14,
              color: warningText.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildExpertiseSection(Color textColor, Color greyText) {
  //   List<String> skills = (job.tags).split(',').where((s) => s.trim().isNotEmpty).toList();

  //   // return Column(
  //   //   crossAxisAlignment: CrossAxisAlignment.start,
  //   //   children: [
  //   //     Text(
  //   //       'Requirements & Expertise',
  //   //       style: TextStyle(
  //   //         fontSize: 18,
  //   //         fontWeight: FontWeight.bold,
  //   //         color: textColor,
  //   //       ),
  //   //     ),
  //   //     const SizedBox(height: 16),
  //   //     // if (skills.isEmpty)
  //   //     //   Text(
  //   //     //     'No specific requirements mentioned.',
  //   //     //     style: TextStyle(color: greyText),
  //   //     //   ),
  //   //     // ...skills.map(
  //   //     //   //(skill) => _buildExpertiseItem(skill.trim(), textColor),
  //   //     // ),
  //   //   ],
  //   // );
  // }

  Widget _buildBottomActionArea(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final String? phoneNumber = job.phoneNumber;
    final String? whatsappNumber = job.whatsappNumber;

    // ✅ If no contact details, hide bottom bar
    if ((phoneNumber == null || phoneNumber.isEmpty) &&
        (whatsappNumber == null || whatsappNumber.isEmpty)) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            /// ✅ CALL BUTTON
            if (phoneNumber != null && phoneNumber.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: phoneNumber,
                      );

                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open dialer'),
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(Icons.phone_outlined, color: primaryGreen),
                    label: Text(
                      'Call',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryGreen, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

            if (phoneNumber != null &&
                phoneNumber.isNotEmpty &&
                whatsappNumber != null &&
                whatsappNumber.isNotEmpty)
              const SizedBox(width: 16),

            
            if (whatsappNumber != null && whatsappNumber.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final String message =
                          "Hi, I am interested in the '${job.title}' job posted on Gem Hub.";

                      final String formattedNumber = formatWhatsAppNumber(
                        job.whatsappNumber!,
                      );

                      final Uri whatsappUri = Uri.parse(
                        "whatsapp://send?phone=$formattedNumber&text=${Uri.encodeComponent(message)}",
                      );

                      try {
                        await launchUrl(
                          whatsappUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Unable to open WhatsApp"),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.chat_outlined, color: Colors.white),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String formatWhatsAppNumber(String number) {
  String cleanNumber = number.replaceAll(RegExp(r'\s+'), '');

  if (cleanNumber.startsWith('+')) {
    cleanNumber = cleanNumber.substring(1);
  }

  if (cleanNumber.startsWith('0')) {
    cleanNumber = '94${cleanNumber.substring(1)}';
  }

  return cleanNumber;
}

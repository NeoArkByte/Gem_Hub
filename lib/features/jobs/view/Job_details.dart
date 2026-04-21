import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 👇 Path tika hariyata check karaganna
import 'package:job_market/features/auth/view/login_screen.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({Key? key, required this.job}) : super(key: key);

  final Color primaryGreen = const Color(0xFF10C971);

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.ios_share, size: 20, color: textColor),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeaderSection(textColor, greyText, isDark),
              const SizedBox(height: 24),
              _buildTagsRow(isDark),
              const SizedBox(height: 32),
              _buildAboutSection(textColor, greyText),
              const SizedBox(height: 24),
              _buildSalaryCard(textColor, greyText, isDark),
              const SizedBox(height: 32),
              _buildExpertiseSection(textColor, greyText),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionArea(context, isDark),
    );
  }

  Widget _buildHeaderSection(Color textColor, Color greyText, bool isDark) {
    List<String> companyParts = job['companyInfo'].toString().split(' • ');
    String companyName = companyParts[0];
    String location = companyParts.length > 1 ? companyParts[1] : 'Remote';

    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF374151) : Colors.grey[200]!,
                width: 2,
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
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                color: Color(job['logoColor'] ?? 0xFF10C971),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Colors.white38,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            job['title'] ?? 'Job Title',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                companyName,
                style: TextStyle(
                  fontSize: 16,
                  color: primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.verified, color: primaryGreen, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$location • Active Listing',
            style: TextStyle(fontSize: 14, color: greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsRow(bool isDark) {
    List<String> tagsList = (job['tags'] as String? ?? '').split(',');

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: tagsList.map((tag) {
        return _buildTag(
          Icons.check_circle_outline,
          tag.trim(),
          isDark ? const Color(0xFF1F2937) : Colors.grey[100]!,
          isDark ? Colors.grey[300]! : const Color(0xFF4B5563),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
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
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Color textColor, Color greyText) {
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
          'We are seeking an experienced professional for the ${job['title'] ?? 'position'}. You will be responsible for handling premium gemstones, maintaining high-quality standards, and working closely with our international teams.',
          style: TextStyle(fontSize: 15, color: greyText, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSalaryCard(Color textColor, Color greyText, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : Colors.grey[200]!,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPECTED SALARY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: greyText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job['salary'] ?? 'Negotiable',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payments_outlined, color: primaryGreen, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseSection(Color textColor, Color greyText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Expertise',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildExpertiseItem(
          'Industry Experience',
          'Prior experience in the gem and jewelry sector.',
          textColor,
          greyText,
        ),
        _buildExpertiseItem(
          'Quality Control',
          'Strict adherence to GIA and AGS grading standards.',
          textColor,
          greyText,
        ),
        _buildExpertiseItem(
          'Reliability',
          'Proven track record of handling high-value materials.',
          textColor,
          greyText,
        ),
      ],
    );
  }

  Widget _buildExpertiseItem(
    String title,
    String description,
    Color textColor,
    Color greyText,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 14, color: primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: greyText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionArea(BuildContext context, bool isDark) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF374151) : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.bookmark_border,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  // 👇 APPLY BUTTON EKE LOGIN CHECK EKA HARIYATA HADUWA
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    // Log welada balanawa
                    bool isLoggedIn = prefs.getString('logged_in_user_id') != null;

                    if (isLoggedIn) {
                      // Log wela nam Form eka open wenawa
                      _showApplyBottomSheet(context, job);
                    } else {
                      // Guest nam Login ekata yawanawa
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in to apply for jobs'))
                        );
                        Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (_) => const LoginScreen())
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply Now',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- POPUP FUNCTION EKA ---
  void _showApplyBottomSheet(
    BuildContext context,
    Map<String, dynamic> jobData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplyJobForm(job: jobData),
    );
  }
}

// ==========================================
// APPLY JOB FORM (BOTTOM SHEET WIDGET)
// ==========================================
class ApplyJobForm extends StatefulWidget {
  final Map<String, dynamic> job; // 👇 Full job map eka illanawa
  const ApplyJobForm({Key? key, required this.job}) : super(key: key);

  @override
  State<ApplyJobForm> createState() => _ApplyJobFormState();
}

class _ApplyJobFormState extends State<ApplyJobForm> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _salaryCtrl = TextEditingController();

  String? _cvFileName;
  String? _cvFilePath;
  bool _isSubmitting = false;

  final Color primaryGreen = const Color(0xFF10C971);

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _cvFilePath = result.files.single.path;
          _cvFileName = result.files.single.name;
        });
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  void _submitForm() async {
    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _cvFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all details and upload your CV'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // 1. Application eka DB ekata danawa
    Map<String, dynamic> application = {
      'job_id': widget.job['id'],
      'applicant_name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'expected_salary': _salaryCtrl.text,
      'cv_path': _cvFilePath,
      'status': 'pending',
    };

    await DatabaseHelper().submitApplication(application);

    // 2. 🔥 NOTIFICATION EKA YAWANAWA 🔥
    await DatabaseHelper().addNotification(
      widget.job['employer_id'], // Job eka dapu Employer ta
      "New Application! 🎉",
      "${_nameCtrl.text} applied for your job: ${widget.job['title']}",
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application Submitted Successfully!'),
          backgroundColor: Color(0xFF10C971),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color fieldBg = isDark ? const Color(0xFF111827) : Colors.white;
    Color borderColor = isDark ? const Color(0xFF374151) : Colors.grey[400]!;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply for this Role',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameCtrl,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: fieldBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: fieldBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _salaryCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Expected Salary (Optional)',
                labelStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: fieldBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGreen, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Resume / CV',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickCV,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _cvFilePath != null ? primaryGreen : borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _cvFilePath != null
                          ? Icons.check_circle
                          : Icons.upload_file,
                      color: _cvFilePath != null
                          ? primaryGreen
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _cvFileName ?? 'Tap to select PDF or Word doc',
                        style: TextStyle(
                          color: _cvFilePath != null
                              ? primaryGreen
                              : Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
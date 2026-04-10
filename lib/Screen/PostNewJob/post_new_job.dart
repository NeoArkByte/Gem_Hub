import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👇 Added for User ID
import 'package:job_market/db/database_helper.dart';
import 'package:job_market/Screen/PostNewJob/post_job_components.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({Key? key}) : super(key: key);

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final Color primaryYellow = const Color(0xFFFDB913);

  final TextEditingController _companyNameCtrl = TextEditingController();
  final TextEditingController _jobTitleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _minSalaryCtrl = TextEditingController();
  final TextEditingController _maxSalaryCtrl = TextEditingController();

  String _selectedLocation = "";
  List<String> _skills = ['Faceting', 'Gemology'];

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
    }
  }

  void _removeSkill(int index) {
    setState(() => _skills.removeAt(index));
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _jobTitleCtrl.dispose();
    _descriptionCtrl.dispose();
    _minSalaryCtrl.dispose();
    _maxSalaryCtrl.dispose();
    super.dispose();
  }

  // 👇 UPDATE KARAPU FUNCTION EKA 👇
  void _publishJob() async {
    if (_jobTitleCtrl.text.isEmpty ||
        _companyNameCtrl.text.isEmpty ||
        _selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields including Location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 1. SharedPreferences walin login wela inna user ge ID eka gannawa
    final prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('logged_in_user_id') ?? 'UNKNOWN';

    String companyInfoFormatted =
        '${_companyNameCtrl.text} • $_selectedLocation';
    String salaryFormatted =
        '\$${_minSalaryCtrl.text} - \$${_maxSalaryCtrl.text}';

    Map<String, dynamic> newJob = {
      'employer_id': currentUserId, // 👈 2. E ID eka Job ekata link karanawa!
      'title': _jobTitleCtrl.text,
      'companyInfo': companyInfoFormatted,
      'salary': salaryFormatted,
      'tags': _skills.isEmpty ? 'NEW' : _skills.join(','),
      'logoColor': 0xFF10C971,
      'status': 'pending',
    };

    await DatabaseHelper().insertJob(newJob);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Job submitted successfully! Waiting for Admin approval.',
          ),
          backgroundColor: Color(0xFF10C971),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8F9FA);
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    Color dividerColor = isDark
        ? const Color(0xFF374151)
        : const Color(0xFFE5E7EB);

    final divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: dividerColor, thickness: 1),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: primaryYellow, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Post a New Job',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'DRAFTS',
                style: TextStyle(
                  color: primaryYellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(color: dividerColor, height: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PostJobHeroSection(textColor: textColor),
                  const SizedBox(height: 32),
                  PostJobSectionHeader(
                    icon: Icons.domain,
                    title: 'COMPANY DETAILS',
                    primaryYellow: primaryYellow,
                  ),
                  const SizedBox(height: 16),
                  PostJobTextField(
                    label: 'Company Name',
                    hint: 'e.g. Royal Gemstone',
                    controller: _companyNameCtrl,
                  ),
                  divider,
                  PostJobSectionHeader(
                    icon: Icons.work_outline,
                    title: 'JOB INFORMATION',
                    primaryYellow: primaryYellow,
                  ),
                  const SizedBox(height: 16),
                  PostJobTextField(
                    label: 'Job Title',
                    hint: 'e.g. Senior Master Gem Cutter',
                    controller: _jobTitleCtrl,
                  ),
                  const SizedBox(height: 20),
                  PostJobTextField(
                    label: 'Job Description',
                    hint: 'Describe the responsibilities...',
                    maxLines: 4,
                    controller: _descriptionCtrl,
                  ),
                  const SizedBox(height: 20),
                  PostJobSkills(
                    primaryYellow: primaryYellow,
                    selectedSkills: _skills,
                    onAddSkill: _addSkill,
                    onRemoveSkill: _removeSkill,
                  ),
                  divider,
                  PostJobSectionHeader(
                    icon: Icons.money,
                    title: 'LOGISTICS',
                    primaryYellow: primaryYellow,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PostJobTextField(
                          label: 'Min Salary',
                          hint: '60,000',
                          prefixIcon: Icons.attach_money,
                          controller: _minSalaryCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PostJobTextField(
                          label: 'Max Salary',
                          hint: '95,000',
                          prefixIcon: Icons.attach_money,
                          controller: _maxSalaryCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PostJobLocationPicker(
                    onPlaceSelected: (String place) {
                      _selectedLocation = place;
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          PostJobBottomAction(
            onPublish: _publishJob,
            bgColor: bgColor,
            primaryYellow: primaryYellow,
          ),
        ],
      ),
    );
  }
}

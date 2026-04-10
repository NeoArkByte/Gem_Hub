import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_market/db/database_helper.dart';
import 'package:job_market/Screen/PostNewJob/post_job_components.dart'; // Path eka hariyata check karaganna

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

  // 👇 ALUTHIN DAMMA: Custom category eka type karanna controller ekak
  final TextEditingController _customCategoryCtrl = TextEditingController();

  String _selectedLocation = "";
  List<String> _skills = ['Faceting', 'Gemology'];

  // 👇 ALUTHIN DAMMA: Gem & Jewelry field eke standard jobs tika
  String _selectedCategory = 'Gem Cutter';
  final List<String> _categories = [
    'Gem Cutter',
    'Polisher',
    'Gemologist',
    'Jewelry Designer',
    'Bench Jeweler',
    'Diamond Grader',
    'Stone Setter',
    'Appraiser',
    'Sales Executive',
    'Intern',
    'Other (Add Custom)', // 👈 Meka select kalama text box eka enawa
  ];

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
    _customCategoryCtrl.dispose();
    super.dispose();
  }

  void _publishJob() async {
    // 1. Validate Karanawa
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

    // "Other" select karala text box eka his nam error ekak denawa
    if (_selectedCategory == 'Other (Add Custom)' &&
        _customCategoryCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your custom job category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. User ID eka gannawa
    final prefs = await SharedPreferences.getInstance();
    String currentUserId = prefs.getString('logged_in_user_id') ?? 'UNKNOWN';

    String companyInfoFormatted =
        '${_companyNameCtrl.text} • $_selectedLocation';
    String salaryFormatted =
        '\$${_minSalaryCtrl.text} - \$${_maxSalaryCtrl.text}';

    // 👇 ALUTH LOGIC EKA: Final category eka hadagannawa
    String finalCategory = _selectedCategory == 'Other (Add Custom)'
        ? _customCategoryCtrl.text.trim()
        : _selectedCategory;

    // Tags walata category ekai skills tikai ekathu karanawa
    String finalTags = '$finalCategory,${_skills.join(',')}';

    Map<String, dynamic> newJob = {
      'employer_id': currentUserId,
      'title': _jobTitleCtrl.text,
      'companyInfo': companyInfoFormatted,
      'salary': salaryFormatted,
      'tags': finalTags,
      'logoColor': 0xFF10C971,
      'status': 'pending',
    };

    await DatabaseHelper().insertJob(newJob);

    // Admin ta Notification eka Yawanawa
    await DatabaseHelper().addNotification(
      'admin',
      "New Job Pending! ⏳",
      "A new job ('${_jobTitleCtrl.text}') has been posted by ${_companyNameCtrl.text}.",
    );

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
    Color fieldBg = isDark ? const Color(0xFF1F2937) : Colors.white;
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

                  // 👇 Job Category Dropdown
                  Text(
                    'Job Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: fieldBg,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: fieldBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryYellow, width: 2),
                      ),
                    ),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),

                  // 👇 METHANA THAMAI MAGIC EKA! 'Other' obama mathu wena text box eka
                  if (_selectedCategory == 'Other (Add Custom)') ...[
                    const SizedBox(height: 16),
                    PostJobTextField(
                      label: 'Type Custom Category',
                      hint: 'e.g. Rough Stone Buyer',
                      controller: _customCategoryCtrl,
                    ),
                  ],

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

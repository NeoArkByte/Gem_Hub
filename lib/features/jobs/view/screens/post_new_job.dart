import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/features/jobs/viewmodels/post_job_viewmodel.dart';
import 'package:gemhub/features/jobs/view/widgets/post_job_components.dart';
import 'package:gemhub/features/auth/viewmodels/admin_screen_viewmodel.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  final Job? jobToEdit;
  final bool isAdmin;

  const PostJobScreen({super.key, this.jobToEdit, this.isAdmin = false});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final Color primaryYellow = const Color(0xFFFDB913);

  final TextEditingController _companyNameCtrl = TextEditingController();
  final TextEditingController _jobTitleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _minSalaryCtrl = TextEditingController();
  final TextEditingController _maxSalaryCtrl = TextEditingController();
  final TextEditingController _customCategoryCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _whatsappCtrl = TextEditingController();

  String _selectedLocation = "";
  List<String> _skills = ['Faceting', 'Gemology'];

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
    'Other (Add Custom)',
  ];

  bool get isEditMode => widget.jobToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final job = widget.jobToEdit!;

      if (job.companyInfo != null && job.companyInfo!.contains(' • ')) {
        final parts = job.companyInfo!.split(' • ');
        _companyNameCtrl.text = parts[0];
        _selectedLocation = parts.length > 1 ? parts[1].trim() : "";
      } else {
        _companyNameCtrl.text = job.companyInfo ?? '';
      }

      _jobTitleCtrl.text = job.title ?? '';
      _descriptionCtrl.text = job.description ?? '';

      if (job.minSalary != null) {
        _minSalaryCtrl.text = job.minSalary!.toInt().toString();
      }
      if (job.maxSalary != null) {
        _maxSalaryCtrl.text = job.maxSalary!.toInt().toString();
      }

      try {
        _phoneCtrl.text = (job as dynamic).phoneNumber ?? '';
        _whatsappCtrl.text = (job as dynamic).whatsappNumber ?? '';
      } catch (e) {
        print("Error accessing phone/whatsapp: $e");
      }

      if (job.tags.isNotEmpty) {
        List<String> allTags = job.tags.split(',');
        if (allTags.isNotEmpty) {
          String cat = allTags.first.trim();
          if (_categories.contains(cat)) {
            _selectedCategory = cat;
          } else {
            _selectedCategory = 'Other (Add Custom)';
            _customCategoryCtrl.text = cat;
          }
          if (allTags.length > 1) {
            _skills = allTags.sublist(1).map((e) => e.trim()).toList();
          } else {
            _skills = [];
          }
        }
      }
    }
  }

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
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  void _publishJob() async {
    if (_companyNameCtrl.text.trim().isEmpty) {
      _showError("Company name is required");
      return;
    }

    if (_jobTitleCtrl.text.trim().isEmpty) {
      _showError("Job title is required");
      return;
    }

    if (_descriptionCtrl.text.trim().length < 20) {
      _showError("Job description must be at least 20 characters");
      return;
    }

    if (_selectedLocation.isEmpty) {
      _showError("Please select job location");
      return;
    }

    if (_skills.isEmpty) {
      _showError("Please add at least one skill");
      return;
    }

    if (_selectedCategory == 'Other (Add Custom)' &&
        _customCategoryCtrl.text.trim().isEmpty) {
      _showError("Please enter custom category");
      return;
    }

    final minSalaryText = _minSalaryCtrl.text.trim();
    final maxSalaryText = _maxSalaryCtrl.text.trim();

    if (minSalaryText.isEmpty && maxSalaryText.isEmpty) {
      _showError("Please enter salary");
      return;
    }

    final parsedMinSalary = minSalaryText.isNotEmpty
        ? double.tryParse(minSalaryText.replaceAll(',', ''))
        : null;

    final parsedMaxSalary = maxSalaryText.isNotEmpty
        ? double.tryParse(maxSalaryText.replaceAll(',', ''))
        : null;

    if ((parsedMinSalary == null && minSalaryText.isNotEmpty) ||
        (parsedMaxSalary == null && maxSalaryText.isNotEmpty)) {
      _showError("Salary must be a valid number");
      return;
    }

    if (parsedMinSalary != null &&
        parsedMaxSalary != null &&
        parsedMinSalary > parsedMaxSalary) {
      _showError("Min salary cannot be greater than Max salary");
      return;
    }

    String phone = _phoneCtrl.text.trim();

    phone = phone.replaceAll(RegExp(r'\s+'), '');

    if (phone.startsWith('0')) {
      phone = '+94${phone.substring(1)}';
    }

    final sriLankaRegex = RegExp(r'^\+94\d{9}$');

    if (!sriLankaRegex.hasMatch(phone)) {
      _showError("Enter a valid Sri Lankan phone number");
      return;
    }

    final sessionState = ref.read(sessionProvider);
    final authData = sessionState.value;

    if (authData == null) {
      _showError("You must be logged in!");
      context.go('/login');
      return;
    }

    final profile = authData.profile;

    if (profile == null || profile.id.isEmpty) {
      _showError("Profile not found. Contact admin.");
      return;
    }

    final String currentEmployerId = profile.id;

    String finalCategory = _selectedCategory == 'Other (Add Custom)'
        ? _customCategoryCtrl.text.trim()
        : _selectedCategory;

    Job submitJob = Job(
      jobId: isEditMode ? widget.jobToEdit!.jobId : null,
      employerId: currentEmployerId,
      title: _jobTitleCtrl.text.trim(),
      companyInfo: '${_companyNameCtrl.text.trim()} • $_selectedLocation',
      minSalary: parsedMinSalary,
      maxSalary: parsedMaxSalary,
      phoneNumber: phone,
      whatsappNumber: _whatsappCtrl.text.trim(),
      tags: '$finalCategory,${_skills.join(',')}',
      status:
          widget.isAdmin ? (widget.jobToEdit?.status ?? 'approved') : 'pending',
      description: _descriptionCtrl.text.trim(),
    );

    bool isSuccess;

    if (isEditMode) {
      isSuccess = await ref
          .read(postJobViewModelProvider.notifier)
          .updateJob(submitJob);
    } else {
      isSuccess = await ref
          .read(postJobViewModelProvider.notifier)
          .publishJob(submitJob);
    }

    if (isSuccess && mounted) {
      ref.invalidate(adminScreenViewModelProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Job updated successfully! Waiting for Admin approval. ⏳'
                : 'Job submitted successfully! Waiting for Admin approval. ⏳',
          ),
          backgroundColor: const Color(0xFFFDB913),
        ),
      );
      context.pop();
    } else if (mounted) {
      _showError(
          isEditMode ? "Failed to update job." : "Failed to submit job.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearMaterialBanners();

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text("DISMISS", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8F9FA);
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    Color fieldBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    Color dividerColor =
        isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    final divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(color: dividerColor, thickness: 1),
    );

    final postJobState = ref.watch(postJobViewModelProvider);
    final isLoading = postJobState is AsyncLoading;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: primaryYellow, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditMode ? 'Edit Job Post' : 'Post a New Job',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
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
                        initialValue: _categories.contains(_selectedCategory)
                            ? _selectedCategory
                            : 'Other (Add Custom)',
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
                            borderSide: BorderSide(
                              color: primaryYellow,
                              width: 2,
                            ),
                          ),
                        ),
                        items: _categories
                            .map(
                              (String category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                        onChanged: (String? newValue) =>
                            setState(() => _selectedCategory = newValue!),
                      ),
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
                              hint: '60000',
                              prefixIcon: Icons.swipe_down_alt_rounded,
                              controller: _minSalaryCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PostJobTextField(
                              label: 'Max Salary',
                              hint: '95000',
                              prefixIcon: Icons.swipe_up_alt_rounded,
                              controller: _maxSalaryCtrl,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      PostJobLocationPicker(
                        onPlaceSelected: (String place) =>
                            _selectedLocation = place,
                      ),
                      const SizedBox(height: 40),
                      PostJobTextField(
                        label: 'Phone Number',
                        hint: '0771234567',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      PostJobTextField(
                        label: 'WhatsApp Number',
                        hint: '0771234567',
                        controller: _whatsappCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              PostJobBottomAction(
                onPublish: isLoading ? () {} : _publishJob,
                bgColor: bgColor,
                primaryYellow: primaryYellow,
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF10C971)),
              ),
            ),
        ],
      ),
    );
  }
}

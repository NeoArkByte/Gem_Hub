import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gemhub/data/models/auth/profile_model.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/shared/widgets/custom_toast.dart';
import 'package:gemhub/features/profile/viewmodel/edit_profile_viewmodel.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileUser profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _descriptionCtrl;
  
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.profile.username);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _descriptionCtrl = TextEditingController(text: widget.profile.description);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image != null) {
      setState(() => _localImagePath = image.path);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(editProfileViewModelProvider.notifier).updateProfile(
          originalProfile: widget.profile,
          username: _usernameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          description: _descriptionCtrl.text,
          newAvatarFile: _localImagePath != null ? File(_localImagePath!) : null,
        );

    if (mounted) {
      if (success) {
        CustomToast.showSuccess(context, 'Profile updated successfully!');
        Navigator.pop(context, true);
      } else {
        CustomToast.showError(context, 'Failed to save changes. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(editProfileViewModelProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color subColor = isDark ? AppColors.greyTextLight : AppColors.greyText;
    final Color dividerColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Edit Account Profile",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                
                GestureDetector(
                  onTap: isSaving ? null : _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBackgroundGrey,
                          backgroundImage: _localImagePath != null
                              ? FileImage(File(_localImagePath!)) as ImageProvider
                              : (widget.profile.avatarUrl != null
                                  ? NetworkImage(widget.profile.avatarUrl!) as ImageProvider
                                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                
                _buildSectionHeader("ACCOUNT CREDENTIALS"),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _usernameCtrl,
                        label: "Username",
                        icon: Icons.person_outline_rounded,
                        iconColor: AppColors.primaryBlue,
                        textColor: textColor,
                        hintColor: subColor,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Username required' : null,
                      ),
                      Divider(height: 1, color: dividerColor),
                      _buildInputField(
                        controller: _emailCtrl,
                        label: "Email Address",
                        icon: Icons.mail_outline_rounded,
                        iconColor: AppColors.gold,
                        textColor: textColor,
                        hintColor: subColor,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Email required' : null,
                      ),
                      Divider(height: 1, color: dividerColor),
                      _buildInputField(
                        controller: _phoneCtrl,
                        label: "Telephone Number",
                        icon: Icons.phone_android_rounded,
                        iconColor: AppColors.accentPurple,
                        textColor: textColor,
                        hintColor: subColor,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

             
                _buildSectionHeader("PUBLIC INTRO"),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
                      width: 1.0,
                    ),
                  ),
                  child: _buildInputField(
                    controller: _descriptionCtrl,
                    label: "Profile Description",
                    icon: Icons.description_outlined,
                    iconColor: AppColors.primaryGreen,
                    textColor: textColor,
                    hintColor: subColor,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 36),

                // Bottom Action Button Blueprint
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text(
                            'Save Modifications',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
        child: Text(
          label,
          style: const TextStyle(
              color: AppColors.greyTextLight,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required Color hintColor,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 12 : 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              validator: validator,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(color: hintColor, fontSize: 13, fontWeight: FontWeight.normal),
                alignLabelWithHint: maxLines > 1,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
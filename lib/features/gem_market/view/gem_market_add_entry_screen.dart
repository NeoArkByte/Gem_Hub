import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_market/features/gem_market/viewmodel/gem_add_viewmodel.dart';
import 'package:job_market/core/constants/app_colors.dart';

class AddGemScreen extends ConsumerStatefulWidget {
  const AddGemScreen({super.key});

  @override
  ConsumerState<AddGemScreen> createState() => _AddGemScreenState();
}

class _AddGemScreenState extends ConsumerState<AddGemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _gemImage;
  File? _certificateFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caratController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sellerPhoneController = TextEditingController();

  bool _isPublishing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caratController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _varietyController.dispose();
    _locationController.dispose();
    _sellerPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gemImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image for the gem.')),
      );
      return;
    }

    setState(() => _isPublishing = true);

    final success = await ref
        .read(gemAddViewModelProvider.notifier)
        .createGem(
          name: _nameController.text.trim(),
          imageFile: _gemImage!,
          certificateFile:
              _certificateFile,
          carat: double.tryParse(_caratController.text.trim()),
          price: double.tryParse(_priceController.text.trim()),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          sellerPhone: _sellerPhoneController.text.trim(),
          variety: _varietyController.text.trim(),
          color: _colorController.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isPublishing = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gem listed successfully and is pending approval.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to list gem. Please check your connection.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _gemImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _certificateFile = File(result.files.single.path!);
      });
    }
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryYellow, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryYellow,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    int maxLines = 1,
    String? suffixText,
    bool optional = false,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color fieldBg = isDark ? AppColors.darkSurface : Colors.white;
    Color labelColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey[400], size: 18)
                : null,
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: AppColors.primaryYellow,
                width: 2,
              ),
            ),
          ),
          validator: optional
              ? null
              : (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter $label'
                    : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildImageTile(String label, File? image, VoidCallback onTap) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color fieldBg = isDark ? AppColors.darkSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.lightBorder,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Center(
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.primaryYellow,
                      size: 30,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileTile(String label, File? file, VoidCallback onTap) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color fieldBg = isDark ? AppColors.darkSurface : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[400] : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkSurfaceAlt
                    : AppColors.lightBorder,
              ),
            ),
            child: file != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            file.path.split(Platform.pathSeparator).last,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.upload_file,
                      color: AppColors.primaryYellow,
                      size: 30,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    Color textColor = isDark ? Colors.white : AppColors.darkBackground;
    Color dividerColor = isDark
        ? AppColors.darkSurfaceAlt
        : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: AppColors.primaryYellow,
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "List New Gem",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Divider(color: dividerColor, height: 1, thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Photos ---
                    _buildSectionHeader(Icons.camera_alt_outlined, 'PHOTOS'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildImageTile(
                            "Gemstone Photo",
                            _gemImage,
                            _pickImage,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFileTile(
                            "Certificate PDF",
                            _certificateFile,
                            _pickCertificate,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),

                    // --- Stone Details ---
                    _buildSectionHeader(
                      Icons.diamond_outlined,
                      'STONE DETAILS',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Gem Name',
                      hint: 'e.g. Royal Blue Sapphire',
                      controller: _nameController,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Variety',
                            hint: 'e.g. Sapphire',
                            controller: _varietyController,
                            optional: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Color',
                            hint: 'e.g. Blue',
                            controller: _colorController,
                            optional: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Carat',
                            hint: '0.00',
                            controller: _caratController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            suffixText: 'ct',
                            optional: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Price',
                            hint: '0',
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            prefixIcon: Icons.payments_outlined,
                            optional: true,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),

                    // --- Seller & Location ---
                    _buildSectionHeader(
                      Icons.location_on_outlined,
                      'SELLER & LOCATION',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Location',
                      hint: 'e.g. Colombo',
                      controller: _locationController,
                      prefixIcon: Icons.map_outlined,
                      optional: true,
                    ),
                    _buildTextField(
                      label: 'Seller Phone',
                      hint: 'e.g. +94 77 123 4567',
                      controller: _sellerPhoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      optional: true,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),

                    // --- Description ---
                    _buildSectionHeader(
                      Icons.description_outlined,
                      'DESCRIPTION',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Description',
                      hint: 'Describe the gem quality and history...',
                      controller: _descriptionController,
                      maxLines: 4,
                      optional: true,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? AppColors.darkBackground : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isPublishing ? null : _handlePublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isPublishing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Publish Gem',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/features/gem_market/viewmodel/gem_update_viewmodel.dart';
import 'package:job_market/core/constants/app_colors.dart';

class UpdateGemScreen extends ConsumerStatefulWidget {
  final Gem gem;
  const UpdateGemScreen({super.key, required this.gem});

  @override
  ConsumerState<UpdateGemScreen> createState() => _UpdateGemScreenState();
}

class _UpdateGemScreenState extends ConsumerState<UpdateGemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _gemImage;
  File? _certificateFile;

  late TextEditingController _nameController;
  late TextEditingController _caratController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _colorController;
  late TextEditingController _varietyController;
  late TextEditingController _locationController;
  late TextEditingController _sellerPhoneController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gem.name);
    _caratController = TextEditingController(text: widget.gem.carat?.toString() ?? '');
    _priceController = TextEditingController(text: widget.gem.price?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.gem.description ?? '');
    _colorController = TextEditingController(text: widget.gem.color ?? '');
    _varietyController = TextEditingController(text: widget.gem.variety ?? '');
    _locationController = TextEditingController(text: widget.gem.location ?? '');
    _sellerPhoneController = TextEditingController(text: widget.gem.sellerPhone ?? '');
  }

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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final success = await ref
        .read(gemUpdateViewModelProvider.notifier)
        .updateGem(
          gemId: widget.gem.gemId!,
          name: _nameController.text.trim(),
          carat: double.tryParse(_caratController.text.trim()),
          price: double.tryParse(_priceController.text.trim()),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          sellerPhone: _sellerPhoneController.text.trim(),
          variety: _varietyController.text.trim(),
          color: _colorController.text.trim(),
          imageUrl: _gemImage?.path ?? widget.gem.imageUrl,
          certificateUrl: _certificateFile?.path ?? widget.gem.certificateUrl,
        );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gem updated successfully.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update gem. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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
              borderSide: BorderSide(color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primaryYellow, width: 2),
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

  Widget _buildImageTile(String label, File? localImage, String? remoteUrl, VoidCallback onTap) {
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
              border: Border.all(color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder),
            ),
            child: localImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(localImage, fit: BoxFit.cover),
                  )
                : (remoteUrl != null && remoteUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          remoteUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(Icons.broken_image, color: Colors.grey[400]),
                          ),
                        ),
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

  Widget _buildFileTile(String label, File? file, String? remoteUrl, VoidCallback onTap) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color fieldBg = isDark ? AppColors.darkSurface : Colors.white;

    bool hasFile = file != null || (remoteUrl != null && remoteUrl.isNotEmpty);
    String fileName = file != null 
        ? file.path.split(Platform.pathSeparator).last 
        : (remoteUrl != null ? remoteUrl.split('/').last : '');

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
              border: Border.all(color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder),
            ),
            child: hasFile
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        if (remoteUrl != null && file == null)
                          const Text(
                            "(Remote)",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
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
    Color bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    Color textColor = isDark ? Colors.white : AppColors.darkBackground;
    Color dividerColor = isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryYellow, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Edit Gem Details",
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
                            widget.gem.imageUrl,
                            _pickImage,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFileTile(
                            "Certificate PDF",
                            _certificateFile,
                            widget.gem.certificateUrl,
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
                    _buildSectionHeader(Icons.diamond_outlined, 'STONE DETAILS'),
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    _buildSectionHeader(Icons.location_on_outlined, 'SELLER & LOCATION'),
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
                    _buildSectionHeader(Icons.description_outlined, 'DESCRIPTION'),
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
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Changes',
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
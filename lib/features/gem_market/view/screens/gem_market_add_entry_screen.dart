import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/features/gem_market/provider/gem_list_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gemhub/features/gem_market/viewmodel/gem_add/gem_add_viewmodel.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_image_picker_tile.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_file_picker_tile.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_form_section_header.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_form_text_field.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_form_dropdown_field.dart';
import 'package:gemhub/shared/widgets/location_picker.dart';

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
  String? _selectedVariety;
  List<String> _varieties = [];
  final TextEditingController _customVarietyController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sellerPhoneController = TextEditingController();
  final FocusNode _customVarietyFocusNode = FocusNode();

  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _loadVarieties();
  }

  Future<void> _loadVarieties() async {
    try {
      final varieties =
          await ref.read(gemAddViewModelProvider.notifier).getGemVarieties();
      if (mounted) {
        setState(() {
          _varieties = List<String>.from(varieties);
          if (!_varieties.contains('Other')) {
            _varieties.add('Other');
          }

          // If _selectedVariety is already set and not in the list, it's a custom variety
          if (_selectedVariety != null &&
              _selectedVariety != 'Other' &&
              !_varieties.contains(_selectedVariety)) {
            _customVarietyController.text = _selectedVariety!;
            _selectedVariety = 'Other';
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading varieties: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caratController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    _customVarietyController.dispose();
    _locationController.dispose();
    _sellerPhoneController.dispose();
    _customVarietyFocusNode.dispose();
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

    final success = await ref.read(gemAddViewModelProvider.notifier).createGem(
          name: _nameController.text.trim(),
          imageFile: _gemImage!,
          certificateFile: _certificateFile,
          carat: double.tryParse(_caratController.text.trim()),
          price: double.tryParse(_priceController.text.trim()),
          description: _descriptionController.text.trim(),
          location: _locationController.text.trim(),
          sellerPhone: _sellerPhoneController.text.trim(),
          variety: _selectedVariety == 'Other'
              ? _customVarietyController.text.trim()
              : _selectedVariety,
          color: _colorController.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isPublishing = false);

    if (success) {
      ref.invalidate(gemListProvider);
      ref.invalidate(userSpecificGemsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gem listed successfully and is pending approval.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to list gem. Please check your connection.'),
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

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    Color textColor = isDark ? Colors.white : AppColors.darkBackground;
    Color dividerColor =
        isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;

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
                    const GemFormSectionHeader(
                      icon: Icons.camera_alt_outlined,
                      title: 'PHOTOS',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GemImagePickerTile(
                            label: "Gemstone Photo",
                            image: _gemImage,
                            onTap: _pickImage,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GemFilePickerTile(
                            label: "Certificate PDF",
                            file: _certificateFile,
                            onTap: _pickCertificate,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),

                    // --- Stone Details ---
                    const GemFormSectionHeader(
                      icon: Icons.diamond_outlined,
                      title: 'STONE DETAILS',
                    ),
                    const SizedBox(height: 16),
                    GemFormTextField(
                      label: 'Gem Name',
                      hint: 'e.g. Royal Blue Sapphire',
                      controller: _nameController,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _selectedVariety == 'Other'
                                ? GemFormTextField(
                                    key: const ValueKey('custom_variety'),
                                    label: 'Variety',
                                    hint: 'Enter variety',
                                    controller: _customVarietyController,
                                    focusNode: _customVarietyFocusNode,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _selectedVariety = null;
                                          _customVarietyController.clear();
                                        });
                                      },
                                    ),
                                  )
                                : GemFormDropdownField(
                                    key: const ValueKey('dropdown_variety'),
                                    label: 'Variety',
                                    hint: 'Select variety',
                                    value: _selectedVariety,
                                    items: _varieties,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedVariety = newValue;
                                        if (newValue == 'Other') {
                                          _customVarietyFocusNode
                                              .requestFocus();
                                        }
                                      });
                                    },
                                    optional: true,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GemFormTextField(
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
                          child: GemFormTextField(
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
                          child: GemFormTextField(
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
                    const GemFormSectionHeader(
                      icon: Icons.location_on_outlined,
                      title: 'SELLER & LOCATION',
                    ),
                    const SizedBox(height: 16),
                    AppLocationPicker(
                      onPlaceSelected: (location) {
                        _locationController.text = location;
                      },
                    ),
                    const SizedBox(height: 20),
                    GemFormTextField(
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
                    const GemFormSectionHeader(
                      icon: Icons.description_outlined,
                      title: 'DESCRIPTION',
                    ),
                    const SizedBox(height: 16),
                    GemFormTextField(
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

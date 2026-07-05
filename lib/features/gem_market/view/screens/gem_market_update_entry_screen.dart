import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/features/gem_market/provider/gem_list_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/features/gem_market/viewmodel/gem_update/gem_update_viewmodel.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_image_picker_tile.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_file_picker_tile.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_form_section_header.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_form_text_field.dart';
import 'package:gemhub/features/gem_market/view/widgets/shared/gem_form_dropdown_field.dart';
import 'package:gemhub/shared/widgets/location_picker.dart';

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
  String? _selectedVariety;
  List<String> _varieties = [];
  late TextEditingController _customVarietyController;
  late TextEditingController _locationController;
  late TextEditingController _sellerPhoneController;
  final FocusNode _customVarietyFocusNode = FocusNode();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gem.name);
    _caratController = TextEditingController(
      text: widget.gem.carat?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.gem.price?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.gem.description ?? '',
    );
    _colorController = TextEditingController(text: widget.gem.color ?? '');
    _selectedVariety = widget.gem.variety;
    _customVarietyController = TextEditingController();
    _locationController = TextEditingController(
      text: widget.gem.location ?? '',
    );
    _sellerPhoneController = TextEditingController(
      text: widget.gem.sellerPhone ?? '',
    );
    _loadVarieties();
  }

  Future<void> _loadVarieties() async {
    try {
      final varieties =
          await ref.read(gemUpdateViewModelProvider.notifier).getGemVarieties();
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or specify a location.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success =
        await ref.read(gemUpdateViewModelProvider.notifier).updateGem(
              gemId: widget.gem.gemId!,
              originalGem: widget.gem,
              name: _nameController.text.trim(),
              carat: double.tryParse(_caratController.text.trim()),
              price: double.tryParse(_priceController.text.trim()),
              description: _descriptionController.text.trim(),
              location: _locationController.text.trim(),
              sellerPhone: _sellerPhoneController.text.trim(),
              variety: _selectedVariety,
              color: _colorController.text.trim(),
              // Directly forward your picked file hooks (they will naturally be null if untouched)
              newImageFile: _gemImage, // Your picked File? object
              newCertificateFile: _certificateFile, // Your picked File? object
            );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      // Invalidate the provider that depends on the user's gems
      ref.invalidate(userSpecificGemsProvider);

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
                            remoteUrl: widget.gem.imageUrl,
                            onTap: _pickImage,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GemFilePickerTile(
                            label: "Certificate PDF",
                            file: _certificateFile,
                            remoteUrl: widget.gem.certificateUrl,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a gem name';
                        }
                        if (value.trim().length < 3) {
                          return 'Gem name must be at least 3 characters';
                        }
                        return null;
                      },
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
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter custom variety';
                                      }
                                      if (value.trim().length < 2) {
                                        return 'Variety name is too short';
                                      }
                                      return null;
                                    },
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
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GemFormTextField(
                            label: 'Color',
                            hint: 'e.g. Blue',
                            controller: _colorController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a color';
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter carat weight';
                              }
                              final carat = double.tryParse(value.trim());
                              if (carat == null || carat <= 0) {
                                return 'Enter a valid weight > 0';
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a price';
                              }
                              final price = double.tryParse(value.trim());
                              if (price == null || price <= 0) {
                                return 'Enter a valid price > 0';
                              }
                              return null;
                            },
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
                      initialValue: _locationController.text,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }
                        final cleanVal =
                            value.replaceAll(RegExp(r'[\s\-()]'), '');
                        final slRegex = RegExp(r'^(?:\+94|94|0)?[1-9]\d{8}$');
                        if (!slRegex.hasMatch(cleanVal)) {
                          return 'Enter a valid Sri Lankan number';
                        }
                        return null;
                      },
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

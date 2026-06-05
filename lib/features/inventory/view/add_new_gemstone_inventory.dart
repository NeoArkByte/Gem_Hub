import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/inventory/media_processing_state.dart';
import 'package:gemhub/features/inventory/viewmodels/add_new_gemstone_viewmodel.dart';

class AddNewGemstoneScreen extends ConsumerStatefulWidget {
  final GemstoneModel? gemstoneToEdit; // Add this line

  const AddNewGemstoneScreen({super.key, this.gemstoneToEdit});

  @override
  ConsumerState<AddNewGemstoneScreen> createState() =>
      _AddNewGemstoneScreenState();
}

class _AddNewGemstoneScreenState extends ConsumerState<AddNewGemstoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  bool _isSold = false;
  String? _firstImageError;

  // --- Media State ---
  File? _firstImage;
  File? _finalImage;
  File? _firstVideo;
  File? _finalVideo;

  String? _rawFirstImagePath;
  String? _rawFinalImagePath;
  String? _rawFirstVideoPath;
  String? _rawFinalVideoPath;

  // --- Controllers ---
  final TextEditingController _dateCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  String _selectedVariety = 'Sapphire';
  final List<String> _varieties = [
    'Sapphire',
    'Ruby',
    'Emerald',
    'Spinel',
    'Tourmaline',
    'Chrysoberyl',
    'Alexandrite',
    'Other',
  ];

  final TextEditingController _colorCtrl = TextEditingController();
  bool _isRough = true;
  bool _isCut = false;

  // Acquisition
  final TextEditingController _buyingWeightCtrl = TextEditingController();
  final TextEditingController _buyingPriceCtrl = TextEditingController(
    text: '0',
  );

  // Value Addition (NEW)
  final TextEditingController _treatmentCostCtrl = TextEditingController(
    text: '0',
  );
  final TextEditingController _recutCostCtrl = TextEditingController(text: '0');
  final TextEditingController _otherValueAddCostCtrl = TextEditingController(
    text: '0',
  );
  final TextEditingController _valueAddDescCtrl =
      TextEditingController(); // Description

  // Processing
  final TextEditingController _treatmentStatusCtrl = TextEditingController();
  final TextEditingController _finalWeightCtrl = TextEditingController();

  // Final Costs & Prices (NEW)
  final TextEditingController _transportCostCtrl = TextEditingController(
    text: '0',
  );
  final TextEditingController _otherExpCostCtrl = TextEditingController(
    text: '0',
  );
  final TextEditingController _otherExpDescCtrl = TextEditingController();
  final TextEditingController _targetPriceCtrl = TextEditingController(
    text: '0',
  );
  final TextEditingController _sellingPriceCtrl = TextEditingController(
    text: '0',
  );

  @override
  void initState() {
    super.initState();

    // Set the default date display
    _dateCtrl.text = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // If editing, pre-fill all fields using your defined controller names
    if (widget.gemstoneToEdit != null) {
      final gem = widget.gemstoneToEdit!;

      // Basic Info
      _dateCtrl.text = gem.date;
      _selectedVariety = gem.variety;
      _colorCtrl.text = gem.color;
      _isRough = gem.isRough;
      _isCut = gem.isCut;

      // Acquisition & Weights
      _buyingWeightCtrl.text = gem.buyingWeight.toString();
      _buyingPriceCtrl.text = gem.buyingPrice.toString();
      _finalWeightCtrl.text = gem.finalWeight.toString();

      // Value Addition
      _treatmentCostCtrl.text = gem.treatmentCost.toString();
      _recutCostCtrl.text = gem.recutCost.toString();
      _valueAddDescCtrl.text = gem.otherProcessingDesc;

      // Final Costs & Target
      _transportCostCtrl.text = gem.transportCost.toString();
      _otherExpCostCtrl.text = gem.otherCost.toString();
      _otherExpDescCtrl.text = gem.otherCostReason;
      _targetPriceCtrl.text = gem.targetPrice.toString();
      _sellingPriceCtrl.text = gem.sellingPrice.toString();

      if (gem.firstImagePath != null) {
        _firstImage = File(gem.firstImagePath!);
      }
      if (gem.finalImagePath != null) {
        _finalImage = File(gem.finalImagePath!);
      }
      if (gem.firstVideoPath != null) {
        _firstVideo = File(gem.firstVideoPath!);
      }
      if (gem.finalVideoPath != null) {
        _finalVideo = File(gem.finalVideoPath!);
      }
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _colorCtrl.dispose();
    _buyingWeightCtrl.dispose();
    _buyingPriceCtrl.dispose();
    _treatmentCostCtrl.dispose();
    _recutCostCtrl.dispose();
    _otherValueAddCostCtrl.dispose();
    _valueAddDescCtrl.dispose();
    _treatmentStatusCtrl.dispose();
    _finalWeightCtrl.dispose();
    _transportCostCtrl.dispose();
    _otherExpCostCtrl.dispose();
    _otherExpDescCtrl.dispose();
    _targetPriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    super.dispose();
  }

  // --- Helper: Calculation Logic ---
  double get _totalFinalCost {
    double buying = double.tryParse(_buyingPriceCtrl.text) ?? 0;
    double treatment = double.tryParse(_treatmentCostCtrl.text) ?? 0;
    double recut = double.tryParse(_recutCostCtrl.text) ?? 0;
    double vAddOther = double.tryParse(_otherValueAddCostCtrl.text) ?? 0;
    double transport = double.tryParse(_transportCostCtrl.text) ?? 0;
    double expOther = double.tryParse(_otherExpCostCtrl.text) ?? 0;
    return buying + treatment + recut + vAddOther + transport + expOther;
  }

  double get _profitAmount {
    double selling = double.tryParse(_sellingPriceCtrl.text) ?? 0;
    return selling - _totalFinalCost;
  }

  double get _profitPercentage {
    if (_totalFinalCost == 0) return 0;
    return (_profitAmount / _totalFinalCost) * 100;
  }

  // --- Image Picker Logic ---
  Future<void> _pickMedia(bool isFirst) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera (Image)'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery (Image)'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video (Gallery)'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // Show another picker for Video if needed, or just handle based on button?
    // Let's re-work the picker to be more explicit.
  }

  Future<void> _pickImage(bool isFirst) async {
    await _handleMediaPick(isFirst, isVideo: false);
  }

  Future<void> _pickVideo(bool isFirst) async {
    await _handleMediaPick(isFirst, isVideo: true);
  }

  Future<void> _handleMediaPick(bool isFirst, {required bool isVideo}) async {
    final XFile? pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final int sizeInBytes = await file.length();
      final double sizeInMb = sizeInBytes / (1024 * 1024);

      if (isVideo) {
        if (sizeInMb > 100) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video size exceeds 100MB limit.')),
            );
          }
          return;
        }
      } else {
        if (sizeInMb > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image size exceeds 10MB limit.')),
            );
          }
          return;
        }
      }

      setState(() {
        if (isVideo) {
          if (isFirst) {
            _firstVideo = file;
            _rawFirstVideoPath = pickedFile.path;
          } else {
            _finalVideo = file;
            _rawFinalVideoPath = pickedFile.path;
          }
        } else {
          if (isFirst) {
            _firstImage = file;
            _rawFirstImagePath = pickedFile.path;
          } else {
            _finalImage = file;
            _rawFinalImagePath = pickedFile.path;
          }
        }
      });
    }
  }

  void _publishInventoryItem() async {
    setState(() {
      _firstImageError = null;
    });

    final double treatmentCost =
        double.tryParse(_treatmentCostCtrl.text) ?? 0.0;
    final double otherProcessingCost =
        double.tryParse(_otherValueAddCostCtrl.text) ?? 0.0;
    final double otherExpenses = double.tryParse(_otherExpCostCtrl.text) ?? 0.0;

    if (_firstImage == null && widget.gemstoneToEdit?.firstImagePath == null) {
      setState(() {
        _firstImageError = 'First Look media is required.';
      });
    }

    if (_treatmentStatusCtrl.text.trim().isEmpty) {
      _treatmentStatusCtrl.text = treatmentCost > 0 ? 'Heated' : 'Unheated';
    }

    if (!_formKey.currentState!.validate() || _firstImageError != null) {
      return;
    }

    if (otherProcessingCost > 0 && _valueAddDescCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a description for other processing cost.',
          ),
        ),
      );
      return;
    }

    if (otherExpenses > 0 && _otherExpDescCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description for other expenses.'),
        ),
      );
      return;
    }

    final int? existingId = widget.gemstoneToEdit?.id;

    final newGem = GemstoneModel(
      id: existingId,
      date: _dateCtrl.text,
      variety: _selectedVariety,
      color: _colorCtrl.text,
      isRough: _isRough,
      isCut: _isCut,
      isSold: _isSold,
      sellingPrice: _isSold
          ? (double.tryParse(_sellingPriceCtrl.text) ?? 0.0)
          : 0.0,
      buyingWeight: double.tryParse(_buyingWeightCtrl.text) ?? 0.0,
      buyingPrice: double.tryParse(_buyingPriceCtrl.text) ?? 0.0,
      treatmentCost: double.tryParse(_treatmentCostCtrl.text) ?? 0.0,
      recutCost: double.tryParse(_recutCostCtrl.text) ?? 0.0,
      otherProcessingCost: double.tryParse(_otherValueAddCostCtrl.text) ?? 0.0,
      otherProcessingDesc: _valueAddDescCtrl.text,
      finalWeight: double.tryParse(_finalWeightCtrl.text) ?? 0.0,
      transportCost: double.tryParse(_transportCostCtrl.text) ?? 0.0,
      otherCost: double.tryParse(_otherExpCostCtrl.text) ?? 0.0,
      otherCostReason: _otherExpDescCtrl.text,
      targetPrice: double.tryParse(_targetPriceCtrl.text) ?? 0.0,
      firstImagePath:
          _firstImage?.path ?? widget.gemstoneToEdit?.firstImagePath,
      finalImagePath:
          _finalImage?.path ?? widget.gemstoneToEdit?.finalImagePath,
      firstVideoPath:
          _firstVideo?.path ?? widget.gemstoneToEdit?.firstVideoPath,
      finalVideoPath:
          _finalVideo?.path ?? widget.gemstoneToEdit?.finalVideoPath,
    );

    try {
      await ref
          .read(addNewGemstoneViewModelProvider.notifier)
          .saveGemstone(
            gem: newGem,
            rawFirstImagePath: _rawFirstImagePath,
            rawFinalImagePath: _rawFinalImagePath,
            rawFirstVideoPath: _rawFirstVideoPath,
            rawFinalVideoPath: _rawFinalVideoPath,
          );

      if (mounted) {
        // Wait for 2 seconds so the user can see the success state in the overlay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the provider alive while this widget is mounted
    ref.watch(addNewGemstoneViewModelProvider);

    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    Color textColor = isDark ? Colors.white : AppColors.darkBackground;
    Color dividerColor = isDark
        ? AppColors.darkSurfaceAlt
        : AppColors.lightBorder;

    final MediaProcessingState state = ref.watch(
      addNewGemstoneViewModelProvider,
    );
    final bool isLoading = state.isLoading || state.isSuccess;

    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.primaryYellow, size: 28),
            onPressed: isLoading ? null : () => Navigator.pop(context),
          ),
          title: Text(
            widget.gemstoneToEdit != null
                ? "Edit Gemstone"
                : "Add New Gemstone",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Stack(
          children: [
            Form(
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
                          _buildSectionHeader(
                            Icons.camera_alt_outlined,
                            'GEMSTONE PHOTOS',
                            AppColors.primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMediaTile(
                                  "First Look (Img)",
                                  _firstImage,
                                  () => _pickImage(true),
                                  isVideo: false,
                                  showError: _firstImageError != null,
                                  errorText: _firstImageError,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMediaTile(
                                  "First Look (Vid)",
                                  _firstVideo,
                                  () => _pickVideo(true),
                                  isVideo: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMediaTile(
                                  "Final Look (Img)",
                                  _finalImage,
                                  () => _pickImage(false),
                                  isVideo: false,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMediaTile(
                                  "Final Look (Vid)",
                                  _finalVideo,
                                  () => _pickVideo(false),
                                  isVideo: true,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(),
                          ),

                          // --- General ---
                          _buildSectionHeader(
                            Icons.calendar_month,
                            'RECORD DATE',
                            AppColors.primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          _buildDatePickerTextField(context: context),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(),
                          ),

                          // --- Stone Details ---
                          _buildSectionHeader(
                            Icons.diamond_outlined,
                            'STONE DETAILS',
                            AppColors.primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildVarietyDropdown(
                                  context,
                                  textColor,
                                  dividerColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  context: context,
                                  label: 'Color/Varietial',
                                  hint: 'e.g. Royal Blue',
                                  controller: _colorCtrl,
                                  validator: (value) {
                                    if (_selectedVariety == 'Other' &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Please enter a color for Other variety.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildBuyingStateSelectors(textColor),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(),
                          ),

                          // --- Acquisition ---
                          _buildSectionHeader(
                            Icons.shopping_bag_outlined,
                            'ACQUISITION METRICS',
                            AppColors.primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  context: context,
                                  label: 'Buying Weight (ct)',
                                  hint: '0.00',
                                  controller: _buyingWeightCtrl,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    final parsed = double.tryParse(value ?? '');
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Buying weight is required.';
                                    }
                                    if (parsed == null || parsed <= 0) {
                                      return 'Enter a valid buying weight.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  context: context,
                                  label: 'Buying Price (Rs)',
                                  hint: '0',
                                  controller: _buyingPriceCtrl,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.currency_rupee,
                                  validator: (value) {
                                    final parsed = double.tryParse(value ?? '');
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Buying price is required.';
                                    }
                                    if (parsed == null || parsed <= 0) {
                                      return 'Enter a valid buying price.';
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

                          // --- Value Addition ---
                          _buildSectionHeader(
                            Icons.auto_awesome,
                            'VALUE ADDITION COSTS',
                            AppColors.primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  context: context,
                                  label: 'Treatment (Cost)',
                                  hint: '0',
                                  controller: _treatmentCostCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  context: context,
                                  label: 'Recut (Cost)',
                                  hint: '0',
                                  controller: _recutCostCtrl,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            context: context,
                            label: 'Other Processing Cost',
                            hint: '0',
                            controller: _otherValueAddCostCtrl,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            context: context,
                            label: 'Value Add Description',
                            hint: 'Details about treatment/recutting...',
                            controller: _valueAddDescCtrl,
                            maxLines: 2,
                            validator: (value) {
                              final otherCost =
                                  double.tryParse(
                                    _otherValueAddCostCtrl.text,
                                  ) ??
                                  0;
                              if (otherCost > 0 &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please describe the other processing cost.';
                              }
                              return null;
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(),
                          ),

                          // --- Processing & Final State ---
                          _buildSectionHeader(
                            Icons.precision_manufacturing_outlined,
                            'FINAL SPECIFICATIONS',
                            AppColors.primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            context: context,
                            label: 'Treatment Status',
                            hint: 'e.g. Unheated',
                            controller: _treatmentStatusCtrl,
                            validator: (value) {
                              final treatmentCost =
                                  double.tryParse(_treatmentCostCtrl.text) ?? 0;
                              if (treatmentCost > 0 &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'If treatment cost is entered, treatment status is required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            context: context,
                            label: 'Final Carat Weight',
                            hint: '0.00',
                            controller: _finalWeightCtrl,
                            keyboardType: TextInputType.number,
                            suffixText: 'ct',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(),
                          ),

                          // --- Financials & Sales Status ---
                          _buildSectionHeader(
                            Icons.query_stats,
                            'FINANCIAL SUMMARY',
                            AppColors.primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            context: context,
                            label: 'Transport Cost',
                            hint: '0',
                            controller: _transportCostCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.local_shipping_outlined,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            context: context,
                            label: 'Other Expenses',
                            hint: '0',
                            controller: _otherExpCostCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.more_horiz,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            context: context,
                            label: 'Expense Description',
                            hint: 'e.g. Lab reports',
                            controller: _otherExpDescCtrl,
                            validator: (value) {
                              final otherExpenses =
                                  double.tryParse(_otherExpCostCtrl.text) ?? 0;
                              if (otherExpenses > 0 &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please describe the other expenses.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Totals Display (Read Only)
                          _buildDisplayBox(
                            "Total Final Cost",
                            "Rs. ${NumberFormat('#,###').format(_totalFinalCost)}",
                            isDark,
                          ),
                          const SizedBox(height: 24),

                          // --- Sales Toggle ---
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: dividerColor),
                            ),
                            child: SwitchListTile(
                              title: Text(
                                "Mark as Sold",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: const Text(
                                "Record selling price to calculate profit",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              value: _isSold,
                              activeColor: AppColors.primaryYellow,
                              onChanged: (bool value) =>
                                  setState(() => _isSold = value),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Conditionally show Target Price vs Selling Price
                          if (!_isSold) ...[
                            _buildTextField(
                              context: context,
                              label: 'Target Price',
                              hint: 'Expected selling price',
                              controller: _targetPriceCtrl,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.track_changes,
                              validator: (value) {
                                final parsed = double.tryParse(value ?? '');
                                if (value == null || value.trim().isEmpty) {
                                  return 'Target price is required.';
                                }
                                if (parsed == null || parsed <= 0) {
                                  return 'Enter a valid target price.';
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    context: context,
                                    label: 'Target Price',
                                    hint: '0',
                                    controller: _targetPriceCtrl,
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.track_changes,
                                    validator: (value) {
                                      final parsed = double.tryParse(
                                        value ?? '',
                                      );
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Target price is required.';
                                      }
                                      if (parsed == null || parsed <= 0) {
                                        return 'Enter a valid target price.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    context: context,
                                    label: 'Selling Price',
                                    hint: 'Final price',
                                    controller: _sellingPriceCtrl,
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.sell_outlined,
                                    validator: (value) {
                                      if (!_isSold) return null;
                                      final parsed = double.tryParse(
                                        value ?? '',
                                      );
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Selling price is required when sold.';
                                      }
                                      if (parsed == null || parsed <= 0) {
                                        return 'Enter a valid selling price.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Profit Metrics (Only if Sold)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDisplayBox(
                                    "Final Profit",
                                    "Rs. ${NumberFormat('#,###').format(_profitAmount)}",
                                    isDark,
                                    color: _profitAmount >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDisplayBox(
                                    "Margin",
                                    "${_profitPercentage.toStringAsFixed(1)}%",
                                    isDark,
                                    color: _profitAmount >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomAction(bgColor, AppColors.primaryYellow),
                ],
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primaryYellow,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          state.isSuccess
                              ? (widget.gemstoneToEdit != null
                                    ? "Updated Successfully"
                                    : "Added Successfully")
                              : "Compressing & Vaulting media...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  // --- UI Components ---

  Widget _buildDisplayBox(
    String label,
    String value,
    bool isDark, {
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTile(
    String label,
    File? file,
    VoidCallback onTap, {
    required bool isVideo,
    bool showError = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: file != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: isVideo
                            ? Container(
                                color: Colors.black12,
                                width: double.infinity,
                                height: double.infinity,
                                child: const Icon(
                                  Icons.movie_creation_outlined,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              )
                            : Image.file(
                                file,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                      ),
                      if (isVideo)
                        const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white70,
                            size: 30,
                          ),
                        ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isVideo) {
                                if (label.contains("First")) {
                                  _firstVideo = null;
                                  _rawFirstVideoPath = null;
                                } else {
                                  _finalVideo = null;
                                  _rawFinalVideoPath = null;
                                }
                              } else {
                                if (label.contains("First")) {
                                  _firstImage = null;
                                  _rawFirstImagePath = null;
                                } else {
                                  _finalImage = null;
                                  _rawFinalImagePath = null;
                                }
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Icon(
                      isVideo
                          ? Icons.videocam_outlined
                          : Icons.add_a_photo_outlined,
                      color: AppColors.primaryYellow,
                      size: 24,
                    ),
                  ),
          ),
        ),
        if (showError && errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(color: Colors.red, fontSize: 10),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    int maxLines = 1,
    String? suffixText,
    String? Function(String?)? validator,
    Color? fillColor,
    Color? textColor,
    Color? labelColor,
    Color? borderColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    fillColor ??= isDark ? const Color(0xFF1F2937) : Colors.white;
    textColor ??= isDark ? Colors.white : Colors.black;
    labelColor ??= isDark ? Colors.grey[300]! : Colors.grey;
    borderColor ??= isDark ? const Color(0xFF374151) : AppColors.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primaryYellow, size: 18)
                : null,
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTextField({required BuildContext context}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    final Color borderColor = isDark
        ? const Color(0xFF374151)
        : AppColors.lightBorder;
    final Color contentColor = isDark ? Colors.white : AppColors.darkBackground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acquisition/Record Date',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dateCtrl,
          readOnly: true,
          style: TextStyle(color: contentColor),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null)
              setState(() {
                _selectedDate = picked;
                _dateCtrl.text = DateFormat('yyyy.MM.dd').format(picked);
              });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            suffixIcon: Icon(Icons.event_note, color: AppColors.primaryYellow),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVarietyDropdown(
    BuildContext context,
    Color textColor,
    Color dividerColor,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color fieldBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stone Variety',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVariety,
          dropdownColor: fieldBg,
          style: TextStyle(color: textColor, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primaryYellow, width: 2),
            ),
          ),
          items: _varieties
              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
              .toList(),
          onChanged: (val) => setState(() => _selectedVariety = val!),
        ),
      ],
    );
  }

  Widget _buildBuyingStateSelectors(Color textColor) {
    return Row(
      children: [
        Checkbox(
          value: _isRough,
          activeColor: AppColors.primaryYellow,
          onChanged: (val) => setState(() => _isRough = val!),
        ),
        Text('Rough', style: TextStyle(color: textColor)),
        const SizedBox(width: 32),
        Checkbox(
          value: _isCut,
          activeColor: AppColors.primaryYellow,
          onChanged: (val) => setState(() => _isCut = val!),
        ),
        Text('Cut', style: TextStyle(color: textColor)),
      ],
    );
  }

  Widget _buildBottomAction(Color bgColor, Color color) {
    final state = ref.watch(addNewGemstoneViewModelProvider);
    final isLoading = state.isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(top: BorderSide(color: AppColors.lightBorder)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : _publishInventoryItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.gemstoneToEdit != null
                        ? "Update Details"
                        : "Publish Item",
                    style: const TextStyle(
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

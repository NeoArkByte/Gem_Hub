import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/features/inventory/provider/inventory_provider.dart';
import 'package:gemhub/features/inventory/validators/gem_form_validator.dart';
import 'package:gemhub/features/inventory/validators/inventory_form_step_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/inventory/value_addition_model.dart';
import 'package:gemhub/data/models/inventory/certificate_model.dart';
import 'package:gemhub/core/enums/inventory_enums.dart';
import 'package:gemhub/features/inventory/viewmodels/add_new_gemstone_viewmodel.dart';
import 'package:gemhub/features/inventory/viewmodels/prediction_viewmodel.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';
import 'package:gemhub/features/inventory/view/widgets/prediction_sheet.dart';
import 'package:gemhub/features/inventory/view/widgets/inventory_update_entry_screen/inventory_update_entry_screen_widgets.dart';


class InventoryUpdateEntryScreen extends ConsumerStatefulWidget {
  final GemstoneModel gemstoneToEdit;
  const InventoryUpdateEntryScreen({super.key, required this.gemstoneToEdit});

  @override
  ConsumerState<InventoryUpdateEntryScreen> createState() =>
      _InventoryUpdateEntryScreenState();
}

class _InventoryUpdateEntryScreenState extends ConsumerState<InventoryUpdateEntryScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isPickingFile = false;

  late GemCategory _category;
  final TextEditingController _customCategoryCtrl = TextEditingController();
  late String _origin;
  final List<String> _origins = [
    'Sri Lanka',
    'Madagascar',
    'Myanmar',
    'Tanzania',
    'Other'
  ];
  late GemVisibility _visibility;

  final TextEditingController _buyingWeightCtrl = TextEditingController();
  final TextEditingController _buyingPriceCtrl = TextEditingController();
  late DateTime _recordDate;
  late DateTime _buyingDate;
  final TextEditingController _buyerNameCtrl = TextEditingController();
  final TextEditingController _buyerContactCtrl = TextEditingController();
  final TextEditingController _varietyCtrl = TextEditingController();
  final TextEditingController _buyingColorCtrl = TextEditingController();

  List<String> _firstLookPhotos = [];
  String? _firstLookVideo;

  List<ValueAdditionModel> _valueAdditions = [];

  final TextEditingController _finalWeightCtrl = TextEditingController();
  late GemShape _shape;
  final TextEditingController _customShapeCtrl = TextEditingController();
  late GemClarity _clarity;
  final TextEditingController _finalColorCtrl = TextEditingController();
  late InventoryGemStatus _status;
  final TextEditingController _lengthCtrl = TextEditingController();
  final TextEditingController _widthCtrl = TextEditingController();
  final TextEditingController _depthCtrl = TextEditingController();

  List<String> _finalPhotos = [];
  String? _finalVideo;

  bool _isCertified = false;
  List<CertificateModel> _certificates = [];

  final TextEditingController _salesTargetPriceCtrl = TextEditingController();
  bool _isReadyToSale = false;
  bool _isSold = false;
  final TextEditingController _actualSoldPriceCtrl = TextEditingController();
  PredictionModel? _prediction;
  bool _isLoadingPrediction = false;
  Timer? _predictionDebounce;

  bool _clarityUserSet = false;
  String? _firstLookMediaError;

  double get _currentBaselineWeight {
    if (_valueAdditions.isNotEmpty) {
      return _valueAdditions.last.currentWeight;
    }
    return double.tryParse(_buyingWeightCtrl.text) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _varietyCtrl.addListener(_refreshPredictionFromInputs);
    _customCategoryCtrl.addListener(_refreshPredictionFromInputs);
    _buyingWeightCtrl.addListener(_refreshPredictionFromInputs);
    _buyingPriceCtrl.addListener(_refreshPredictionFromInputs);
    _buyingColorCtrl.addListener(_refreshPredictionFromInputs);
    _finalColorCtrl.addListener(_refreshPredictionFromInputs);
    _finalWeightCtrl.addListener(_refreshPredictionFromInputs);

    _loadExistingGemstone(widget.gemstoneToEdit);
    _clarityUserSet = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadPredictionIfEligible();
    });
  }

  void _loadExistingGemstone(GemstoneModel gem) {
    try {
      _category = GemCategory.values.firstWhere(
          (e) => e.displayName == gem.category,
          orElse: () => GemCategory.other);
    } catch (_) {
      _category = GemCategory.other;
    }
    if (_category == GemCategory.other) _customCategoryCtrl.text = gem.category;

    _origin = gem.origin.isNotEmpty ? gem.origin : 'Sri Lanka';
    if (!_origins.contains(_origin)) _origin = 'Other';

    try {
      _visibility = GemVisibility.values.firstWhere(
          (e) => e.displayName == gem.visibility,
          orElse: () => GemVisibility.private);
    } catch (_) {
      _visibility = GemVisibility.private;
    }

    _buyingWeightCtrl.text = gem.buyingWeight.toString();
    _buyingPriceCtrl.text = gem.buyingPrice.toString();

    try {
      _recordDate = DateTime.parse(gem.recordDate);
    } catch (_) {
      _recordDate = DateTime.now();
    }

    try {
      _buyingDate = DateTime.parse(gem.buyingDate);
    } catch (_) {
      _buyingDate = DateTime.now();
    }

    _buyerNameCtrl.text = gem.buyerName;
    _buyerContactCtrl.text = gem.buyerContact;
    _varietyCtrl.text = gem.variety;
    _buyingColorCtrl.text = gem.buyingColor;

    _firstLookPhotos = List.from(gem.firstLookPhotos);
    _firstLookVideo = gem.firstLookVideo;

    _valueAdditions = List.from(gem.valueAdditions);

    _finalWeightCtrl.text = gem.finalWeight > 0
        ? gem.finalWeight.toString()
        : gem.currentWeight.toString();
    try {
      _shape = GemShape.values.firstWhere((e) => e.displayName == gem.shape,
          orElse: () => GemShape.other);
    } catch (_) {
      _shape = GemShape.other;
    }
    if (_shape == GemShape.other) _customShapeCtrl.text = gem.shape;

    try {
      _clarity = GemClarity.values.firstWhere(
          (e) => e.displayName == gem.clarity,
          orElse: () => GemClarity.vvs1);
    } catch (_) {
      _clarity = GemClarity.vvs1;
    }

    _finalColorCtrl.text = gem.finalColor;
    try {
      _status = InventoryGemStatus.values.firstWhere(
          (e) => e.displayName == gem.status,
          orElse: () => InventoryGemStatus.rough);
    } catch (_) {
      _status = gem.isCut ? InventoryGemStatus.cut : InventoryGemStatus.rough;
    }

    _lengthCtrl.text = gem.length.toString();
    _widthCtrl.text = gem.width.toString();
    _depthCtrl.text = gem.depth.toString();

    _finalPhotos = List.from(gem.finalPhotos);
    _finalVideo = gem.finalVideo;

    _isCertified = gem.isCertified;
    _certificates = List.from(gem.certificates);

    _salesTargetPriceCtrl.text = gem.salesTargetPrice.toString();
    _isReadyToSale = gem.isReadyToSale;
    _isSold = gem.isSold;
    _actualSoldPriceCtrl.text = gem.actualSoldPrice.toString();
  }

  @override
  void dispose() {
    _predictionDebounce?.cancel();
    _varietyCtrl.removeListener(_refreshPredictionFromInputs);
    _customCategoryCtrl.removeListener(_refreshPredictionFromInputs);
    _buyingWeightCtrl.removeListener(_refreshPredictionFromInputs);
    _buyingPriceCtrl.removeListener(_refreshPredictionFromInputs);
    _buyingColorCtrl.removeListener(_refreshPredictionFromInputs);
    _finalColorCtrl.removeListener(_refreshPredictionFromInputs);
    _finalWeightCtrl.removeListener(_refreshPredictionFromInputs);
    _customCategoryCtrl.dispose();
    _buyingWeightCtrl.dispose();
    _buyingPriceCtrl.dispose();
    _buyerNameCtrl.dispose();
    _buyerContactCtrl.dispose();
    _varietyCtrl.dispose();
    _buyingColorCtrl.dispose();
    _finalWeightCtrl.dispose();
    _customShapeCtrl.dispose();
    _finalColorCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _depthCtrl.dispose();
    _salesTargetPriceCtrl.dispose();
    _actualSoldPriceCtrl.dispose();
    super.dispose();
  }

  double get _totalValueAdditionCosts =>
      _valueAdditions.fold(0.0, (sum, addition) => sum + addition.cost);
  double get _totalCertificateFees =>
      _certificates.fold(0.0, (sum, cert) => sum + cert.certificateFees);

  double get _totalFinalCost {
    double buying = double.tryParse(_buyingPriceCtrl.text) ?? 0;
    return buying + _totalValueAdditionCosts + _totalCertificateFees;
  }

  double get _targetProfit {
    double salesTarget = double.tryParse(_salesTargetPriceCtrl.text) ?? 0;
    return salesTarget > 0 ? (salesTarget - _totalFinalCost) : 0;
  }

  double get _targetMargin {
    double salesTarget = double.tryParse(_salesTargetPriceCtrl.text) ?? 0;
    return (salesTarget > 0 && _totalFinalCost > 0)
        ? (_targetProfit / _totalFinalCost) * 100
        : 0.0;
  }

  double get _actualProfit {
    double actualSold = double.tryParse(_actualSoldPriceCtrl.text) ?? 0;
    return (_isSold && actualSold > 0) ? (actualSold - _totalFinalCost) : 0;
  }

  double get _actualMargin {
    return (_isSold && _totalFinalCost > 0)
        ? (_actualProfit / _totalFinalCost) * 100
        : 0.0;
  }

  double get _currentWeight {
    if (_valueAdditions.isNotEmpty) {
      return _valueAdditions.last.currentWeight;
    }
    return double.tryParse(_buyingWeightCtrl.text) ?? 0.0;
  }

  void _refreshPredictionFromInputs() {
    _predictionDebounce?.cancel();
    _predictionDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _loadPredictionIfEligible();
      }
    });
  }

  double? _getPredictionWeight() {
    final finalWeight = double.tryParse(_finalWeightCtrl.text);
    if (finalWeight != null && finalWeight > 0) {
      return finalWeight;
    }

    final buyingWeight = double.tryParse(_buyingWeightCtrl.text);
    if (buyingWeight != null && buyingWeight > 0) {
      return buyingWeight;
    }

    return null;
  }

  Future<void> _loadPredictionIfEligible() async {
    final selectedGemType = _varietyCtrl.text.trim().isNotEmpty
        ? _varietyCtrl.text.trim()
        : (_category == GemCategory.other
            ? (_customCategoryCtrl.text.trim().isNotEmpty
                ? _customCategoryCtrl.text.trim()
                : _category.displayName)
            : _category.displayName);

    if (selectedGemType.isEmpty) {
      if (mounted) {
        setState(() {
          _prediction = null;
          _isLoadingPrediction = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingPrediction = true;
      });
    }

    final enteredPrice = double.tryParse(_buyingPriceCtrl.text);
    final purchasePrice =
        (enteredPrice != null && enteredPrice > 0) ? enteredPrice : null;
    final clarityArg = _clarityUserSet ? _clarity.displayName : null;

    try {
      final prediction =
          await ref.read(predictionViewModelProvider).loadPrediction(
                gemType: selectedGemType,
                category: _category.displayName,
                origin: _origin,
                purchasePrice: purchasePrice,
                weight: _getPredictionWeight(),
                color: _buyingColorCtrl.text.trim().isNotEmpty
                    ? _buyingColorCtrl.text.trim()
                    : _finalColorCtrl.text.trim().isNotEmpty
                        ? _finalColorCtrl.text.trim()
                        : null,
                clarity: clarityArg,
              );
      if (mounted) {
        setState(() {
          _prediction = prediction;
          _isLoadingPrediction = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _prediction = PredictionModel.empty(gemType: selectedGemType);
          _isLoadingPrediction = false;
        });
      }
    }
  }

  Color _confidenceColor(String level) {
    switch (level) {
      case 'High':
        return AppColors.successGreen;
      case 'Medium':
        return AppColors.primaryYellow;
      default:
        return AppColors.accentRed;
    }
  }

  void _showPredictionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PredictionSheet(
        prediction: _prediction,
        isLoading: _isLoadingPrediction,
        confidenceColor: _confidenceColor,
      ),
    );
  }

  void _showAiPromptDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('AI Business Prediction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: const Text(
          'Would you like to see an AI-powered business prediction\nbased on similar historical records for this gem?',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Skip'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _showPredictionBottomSheet();
            },
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Yes, show me'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }



  Future<void> _pickImage(List<String> list, int maxPhotos) async {
    if (_isPickingFile) return;
    if (list.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $maxPhotos photos allowed.')),
      );
      return;
    }

    setState(() {
      _isPickingFile = true;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          final String path = image.path;
          if (!list.contains(path)) {
            list.add(path);
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  Future<void> _pickVideo(Function(String?) onPicked) async {
    if (_isPickingFile) return;
    setState(() {
      _isPickingFile = true;
    });

    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          onPicked(video.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking video: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isPickingFile = false;
        });
      }
    }
  }

  void _addValueAddition() {
    showDialog(
      context: context,
      builder: (context) {
        CostType type = CostType.treatment;
        final nameCtrl = TextEditingController();
        final reasonCtrl = TextEditingController();
        final costCtrl = TextEditingController();
        final weightCtrl =
            TextEditingController(text: _currentWeight.toString());
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final formKey = GlobalKey<FormState>();

            return AlertDialog(
              title: const Text('Add Value Addition'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<CostType>(
                        initialValue: type,
                        items: CostType.values
                            .map((e) => DropdownMenuItem(
                                value: e, child: Text(e.displayName)))
                            .toList(),
                        onChanged: (val) => setStateDialog(() => type = val!),
                        decoration:
                            const InputDecoration(labelText: 'Cost Type'),
                      ),
                      if (type == CostType.treatment)
                        TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                                labelText: 'Treatment Name')),
                      if (type == CostType.other)
                        TextFormField(
                            controller: reasonCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Reason')),
                      TextFormField(
                        controller: costCtrl,
                        decoration: const InputDecoration(labelText: 'Cost'),
                        keyboardType: TextInputType.number,
                        validator: GemFormValidator.validateValueAdditionCost,
                      ),
                      TextFormField(
                        controller: weightCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Current Weight (ct)'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            GemFormValidator.validateValueAdditionWeight(
                          value,
                          _currentWeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    setState(() {
                      _valueAdditions.add(ValueAdditionModel(
                        costType: type,
                        treatmentName: nameCtrl.text,
                        reason: reasonCtrl.text,
                        cost: double.tryParse(costCtrl.text) ?? 0.0,
                        currentWeight: double.tryParse(weightCtrl.text) ?? 0.0,
                      ));

                      _finalWeightCtrl.text = weightCtrl.text;
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addCertificate() {
    showDialog(
      context: context,
      builder: (context) {
        final labCtrl = TextEditingController();
        final feeCtrl = TextEditingController();
        List<String> images = [];
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Certificate'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                        controller: labCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Lab Name')),
                    TextFormField(
                      controller: feeCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Certificate Fees'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (_isPickingFile) return;
                        if (images.length >= 2) return;
                        setState(() {
                          _isPickingFile = true;
                        });
                        try {
                          final img = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (img != null) {
                            setStateDialog(() => images.add(img.path));
                          }
                        } catch (e) {
                          debugPrint("Error picking dialog image: $e");
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isPickingFile = false;
                            });
                          }
                        }
                      },
                      child: Text('Add Image (${images.length}/2)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _certificates.add(CertificateModel(
                        labName: labCtrl.text,
                        certificateFees: double.tryParse(feeCtrl.text) ?? 0.0,
                        images: images,
                      ));
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Step> _buildSteps() {
    return [
      // ── STEP 1: BASIC INFO ──────────────────────────────────────────────────
      Step(
        title: const Text('Basic Info'),
        content: Column(
          children: [
            InventoryFormDropdownField<GemCategory>(
              label: 'Category *',
              hint: 'Select category',
              value: _category,
              items: GemCategory.values,
              itemLabelBuilder: (e) => e.displayName,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _category = val;
                    if (_category != GemCategory.other) {
                      _varietyCtrl.text = _category.displayName;
                    } else {
                      _varietyCtrl.text = _customCategoryCtrl.text;
                    }
                  });
                  _refreshPredictionFromInputs();
                }
              },
            ),
            if (_category == GemCategory.other) ...[
              InventoryFormTextField(
                label: 'Custom Category *',
                hint: 'Enter custom category',
                controller: _customCategoryCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ],
            InventoryFormDropdownField<String>(
              label: 'Origin',
              hint: 'Select origin',
              value: _origin,
              items: _origins,
              itemLabelBuilder: (e) => e,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _origin = val);
                  _refreshPredictionFromInputs();
                }
              },
            ),
            InventoryFormDropdownField<GemVisibility>(
              label: 'Visibility',
              hint: 'Select visibility',
              value: _visibility,
              items: GemVisibility.values,
              itemLabelBuilder: (e) => e.displayName,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _visibility = val);
                }
              },
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),

      // ── STEP 2: BUYING DETAILS ──────────────────────────────────────────────
      Step(
        title: const Text('Buying Details'),
        content: Column(
          children: [
            InventoryFormTextField(
              label: 'Buying Weight (ct) *',
              hint: 'Enter buying weight',
              controller: _buyingWeightCtrl,
              keyboardType: TextInputType.number,
              validator: GemFormValidator.validateBuyingWeight,
            ),
            InventoryFormTextField(
              label: 'Buying Price *',
              hint: 'Enter buying price',
              controller: _buyingPriceCtrl,
              keyboardType: TextInputType.number,
              validator: GemFormValidator.validateBuyingPrice,
            ),
            InventoryDatePickerTile(
              label: 'Buying Date',
              date: _buyingDate,
              onSelect: (d) => setState(() => _buyingDate = d),
            ),
            InventoryFormTextField(
              label: 'Buyer Name (Optional)',
              hint: 'Enter buyer name',
              controller: _buyerNameCtrl,
              optional: true,
            ),
            InventoryFormTextField(
              label: 'Buyer Contact Number (Optional)',
              hint: 'Enter contact number',
              controller: _buyerContactCtrl,
              optional: true,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: _varietyCtrl,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Variety (Auto-Populated)',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
            ),
            InventoryFormTextField(
              label: 'Buying Color *',
              hint: 'Enter color',
              controller: _buyingColorCtrl,
              validator: GemFormValidator.validateBuyingColor,
            ),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),

      // ── STEP 3: FIRST LOOK MEDIA ────────────────────────────────────────────
      Step(
        title: const Text('First Look'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(_firstLookPhotos, 4),
              child: Text('Add Photo (${_firstLookPhotos.length}/4)'),
            ),
            Wrap(
              spacing: 8,
              children: _firstLookPhotos
                  .map((path) => Chip(
                        label: const Text('Photo'),
                        onDeleted: () =>
                            setState(() => _firstLookPhotos.remove(path)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  _pickVideo((path) => setState(() => _firstLookVideo = path)),
              child:
                  Text(_firstLookVideo != null ? 'Change Video' : 'Add Video'),
            ),
            if (_firstLookMediaError != null) ...[
              const SizedBox(height: 12),
              Text(
                _firstLookMediaError!,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),

      // ── STEP 4: VALUE ADDITIONS ─────────────────────────────────────────────
      Step(
        title: const Text('Value Additions'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _addValueAddition,
              icon: const Icon(Icons.add),
              label: const Text('Add Value Addition'),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _valueAdditions.length,
              itemBuilder: (context, index) {
                final va = _valueAdditions[index];
                return ListTile(
                  title: Text('${va.costType.displayName} - Rs. ${va.cost}'),
                  subtitle: Text('Weight: ${va.currentWeight} ct'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        setState(() => _valueAdditions.removeAt(index)),
                  ),
                );
              },
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),

      // ── STEP 5: FINAL STAGE ─────────────────────────────────────────────────
      Step(
        title: const Text('Final Stage'),
        content: Column(
          children: [
            InventoryFormTextField(
              label: 'Final Weight (ct) *',
              hint: 'Enter final weight',
              controller: _finalWeightCtrl,
              keyboardType: TextInputType.number,
              validator: (v) => GemFormValidator.validateFinalWeight(
                  v, _currentBaselineWeight),
            ),
            InventoryFormDropdownField<GemShape>(
              label: 'Shape',
              hint: 'Select shape',
              value: _shape,
              items: GemShape.values,
              itemLabelBuilder: (e) => e.displayName,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _shape = val);
                }
              },
            ),
            if (_shape == GemShape.other) ...[
              InventoryFormTextField(
                label: 'Custom Shape',
                hint: 'Enter shape',
                controller: _customShapeCtrl,
              ),
            ],
            InventoryFormDropdownField<GemClarity>(
              label: 'Clarity',
              hint: 'Select clarity',
              value: _clarity,
              items: GemClarity.values,
              itemLabelBuilder: (e) => e.displayName,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _clarity = val;
                    _clarityUserSet = true;
                  });
                  _refreshPredictionFromInputs();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                controller: _buyingColorCtrl,
                decoration: const InputDecoration(
                  labelText: 'Final Color',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Final color is required';
                  }
                  return null;
                },
              ),
            ),
            InventoryFormDropdownField<InventoryGemStatus>(
              label: 'Status',
              hint: 'Select status',
              value: _status,
              items: InventoryGemStatus.values,
              itemLabelBuilder: (e) => e.displayName,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _status = val);
                }
              },
            ),
            if (_status == InventoryGemStatus.cut) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Dimensions (Required for Cut Status) *',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InventoryFormTextField(
                      label: 'Length *',
                      hint: 'L',
                      controller: _lengthCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => GemFormValidator.validateDimension(
                          v, _status.displayName),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InventoryFormTextField(
                      label: 'Width *',
                      hint: 'W',
                      controller: _widthCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => GemFormValidator.validateDimension(
                          v, _status.displayName),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InventoryFormTextField(
                      label: 'Depth *',
                      hint: 'D',
                      controller: _depthCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => GemFormValidator.validateDimension(
                          v, _status.displayName),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),

      // ── STEP 6: FINAL MEDIA ─────────────────────────────────────────────────
      Step(
        title: const Text('Final Media'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(_finalPhotos, 4),
              child: Text('Add Final Photo (${_finalPhotos.length}/4)'),
            ),
            Wrap(
              spacing: 8,
              children: _finalPhotos
                  .map((path) => Chip(
                        label: const Text('Photo'),
                        onDeleted: () =>
                            setState(() => _finalPhotos.remove(path)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  _pickVideo((path) => setState(() => _finalVideo = path)),
              child: Text(_finalVideo != null
                  ? 'Change Final Video'
                  : 'Add Final Video'),
            ),
          ],
        ),
        isActive: _currentStep >= 5,
        state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      ),

      // ── STEP 7: CERTIFICATION ───────────────────────────────────────────────
      Step(
        title: const Text('Certification'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Is this certified?'),
              value: _isCertified,
              onChanged: (v) => setState(() => _isCertified = v),
            ),
            if (_isCertified) ...[
              ElevatedButton.icon(
                onPressed: _addCertificate,
                icon: const Icon(Icons.add),
                label: const Text('Add Certificate'),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _certificates.length,
                itemBuilder: (context, index) {
                  final cert = _certificates[index];
                  return ListTile(
                    title: Text(cert.labName),
                    subtitle: Text('Fee: Rs. ${cert.certificateFees}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          setState(() => _certificates.removeAt(index)),
                    ),
                  );
                },
              ),
            ]
          ],
        ),
        isActive: _currentStep >= 6,
        state: _currentStep > 6 ? StepState.complete : StepState.indexed,
      ),

      // ── STEP 8: FINANCE & SALES ─────────────────────────────────────────────
      Step(
        title: const Text('Finance & Sales'),
        content: Column(
          children: [
            InventoryPredictionCard(
              prediction: _prediction,
              isLoadingPrediction: _isLoadingPrediction,
              confidenceColor: _confidenceColor,
            ),
            ListTile(
              title: const Text('Total Final Cost'),
              trailing: Text('Rs. ${_totalFinalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            InventoryFormTextField(
              label: 'Sales Target Price',
              hint: 'Enter target price',
              controller: _salesTargetPriceCtrl,
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: const Text('Target Profit / Margin'),
              trailing: Text(
                  'Rs. ${_targetProfit.toStringAsFixed(2)} / ${_targetMargin.toStringAsFixed(2)}%'),
            ),
            SwitchListTile(
              title: const Text('Ready To Sale'),
              value: _isReadyToSale,
              onChanged: (v) => setState(() => _isReadyToSale = v),
            ),
            SwitchListTile(
              title: const Text('Sold'),
              value: _isSold,
              onChanged: (v) => setState(() => _isSold = v),
            ),
            if (_isSold) ...[
              InventoryFormTextField(
                label: 'Actual Sold Price',
                hint: 'Enter sold price',
                controller: _actualSoldPriceCtrl,
                keyboardType: TextInputType.number,
              ),
              ListTile(
                title: const Text('Actual Profit / Margin'),
                trailing: Text(
                    'Rs. ${_actualProfit.toStringAsFixed(2)} / ${_actualMargin.toStringAsFixed(2)}%'),
              ),
            ]
          ],
        ),
        isActive: _currentStep >= 7,
        state: StepState.indexed,
      ),
    ];
  }

  bool _validateCurrentStep() {
    setState(() {
      _firstLookMediaError = null;
    });

    final result = InventoryFormStepValidator.validateStep(
      step: _currentStep,
      category: _category,
      varietyCtrl: _varietyCtrl,
      customCategoryCtrl: _customCategoryCtrl,
      buyingWeightCtrl: _buyingWeightCtrl,
      buyingPriceCtrl: _buyingPriceCtrl,
      buyingColorCtrl: _buyingColorCtrl,
      buyerContactCtrl: _buyerContactCtrl,
      finalColorCtrl: _finalColorCtrl,
      finalWeightCtrl: _finalWeightCtrl,
      currentBaselineWeight: _currentBaselineWeight,
      firstLookPhotos: _firstLookPhotos,
      firstLookVideo: _firstLookVideo,
      isCertified: _isCertified,
      certificates: _certificates,
    );

    if (!result.isValid) {
      if (result.errorMessage != null) {
        if (_currentStep == 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.errorMessage!)),
          );
        } else {
          setState(() => _firstLookMediaError = result.errorMessage);
        }
      }
      return false;
    }

    return true;
  }

  bool _validateAllSteps() {
    return InventoryFormStepValidator.validateAllSteps(
      formKey: _formKey,
      buyingWeightCtrl: _buyingWeightCtrl,
      buyingPriceCtrl: _buyingPriceCtrl,
      finalWeightCtrl: _finalWeightCtrl,
    );
  }

  void _publishInventoryItem() async {
    if (!_validateAllSteps()) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please complete all required fields'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }

    final updatedGem = GemstoneModel(
      id: widget.gemstoneToEdit.id,
      category: _category == GemCategory.other
          ? _customCategoryCtrl.text
          : _category.displayName,
      origin: _origin,
      visibility: _visibility.displayName,
      recordDate: _recordDate.toIso8601String(),
      buyingDate: _buyingDate.toIso8601String(),
      buyerName: _buyerNameCtrl.text,
      buyerContact: _buyerContactCtrl.text,
      buyingWeight: double.tryParse(_buyingWeightCtrl.text) ?? 0.0,
      buyingPrice: double.tryParse(_buyingPriceCtrl.text) ?? 0.0,
      variety: _varietyCtrl.text,
      buyingColor: _buyingColorCtrl.text,
      finalColor: _finalColorCtrl.text,
      isRough: _status == InventoryGemStatus.rough,
      isCut: _status == InventoryGemStatus.cut,
      valueAdditions: _valueAdditions,
      currentWeight: _currentWeight,
      finalWeight: double.tryParse(_finalWeightCtrl.text) ?? 0.0,
      shape:
          _shape == GemShape.other ? _customShapeCtrl.text : _shape.displayName,
      clarity: _clarity.displayName,
      status: _status.displayName,
      length: double.tryParse(_lengthCtrl.text) ?? 0.0,
      width: double.tryParse(_widthCtrl.text) ?? 0.0,
      depth: double.tryParse(_depthCtrl.text) ?? 0.0,
      isCertified: _isCertified,
      certificates: _certificates,
      isReadyToSale: _isReadyToSale,
      isSold: _isSold,
      salesTargetPrice: double.tryParse(_salesTargetPriceCtrl.text) ?? 0.0,
      actualSoldPrice: double.tryParse(_actualSoldPriceCtrl.text) ?? 0.0,
      firstLookPhotos: _firstLookPhotos,
      finalPhotos: _finalPhotos,
    );

    try {
      await ref.read(addNewGemstoneViewModelProvider.notifier).saveGemstone(
            gem: updatedGem,
            rawFirstLookPhotos: _firstLookPhotos,
            rawFirstLookVideo: _firstLookVideo,
            rawFinalPhotos: _finalPhotos,
            rawFinalVideo: _finalVideo,
          );
      ref.invalidate(inventoryProvider);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final state = ref.watch(addNewGemstoneViewModelProvider);
    final isLoading = state.isLoading;

    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: const Text('Edit Gemstone'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: 'AI Business Prediction',
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _showPredictionBottomSheet,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('AI',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator(value: state.progress))
            : Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Stepper(
                  physics: const ClampingScrollPhysics(),
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_validateCurrentStep()) {
                      final steps = _buildSteps();

                      if (_currentStep < steps.length - 1) {
                        setState(() => _currentStep += 1);

                        if (_currentStep == 2) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _showAiPromptDialog(),
                          );
                        }
                      } else {
                        _publishInventoryItem();
                      }
                    } else {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please complete all required fields'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) setState(() => _currentStep -= 1);
                  },
                  onStepTapped: (step) => setState(() => _currentStep = step),
                  steps: _buildSteps(),
                  controlsBuilder: (context, details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors.primaryYellow,
                              ),
                              child: Text(
                                  _currentStep == _buildSteps().length - 1
                                      ? 'PUBLISH'
                                      : 'NEXT',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          if (_currentStep > 0) const SizedBox(width: 12),
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: details.onStepCancel,
                                style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16)),
                                child: const Text('BACK'),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

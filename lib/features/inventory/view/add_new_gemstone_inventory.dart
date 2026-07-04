//lib\features\inventory\view\add_new_gemstone_inventory.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/features/inventory/validators/gem_form_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/inventory/value_addition_model.dart';
import 'package:gemhub/data/models/inventory/certificate_model.dart';
import 'package:gemhub/core/enums/inventory_enums.dart';
import 'package:gemhub/features/inventory/viewmodels/add_new_gemstone_viewmodel.dart';
import 'package:gemhub/features/inventory/viewmodels/prediction_viewmodel.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';

class AddNewGemstoneScreen extends ConsumerStatefulWidget {
  final GemstoneModel? gemstoneToEdit;
  const AddNewGemstoneScreen({super.key, this.gemstoneToEdit});

  @override
  ConsumerState<AddNewGemstoneScreen> createState() =>
      _AddNewGemstoneScreenState();
}

class _AddNewGemstoneScreenState extends ConsumerState<AddNewGemstoneScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // STEP 1 - Basic Info
  GemCategory _category = GemCategory.sapphire;
  final TextEditingController _customCategoryCtrl = TextEditingController();
  String _origin = 'Sri Lanka';
  final List<String> _origins = [
    'Sri Lanka',
    'Madagascar',
    'Myanmar',
    'Tanzania',
    'Other'
  ];
  GemVisibility _visibility = GemVisibility.private;

  // STEP 2 - Buying Details
  final TextEditingController _buyingWeightCtrl = TextEditingController();
  final TextEditingController _buyingPriceCtrl =
      TextEditingController(text: '0');
  DateTime _recordDate = DateTime.now();
  DateTime _buyingDate = DateTime.now();
  final TextEditingController _buyerNameCtrl = TextEditingController();
  final TextEditingController _buyerContactCtrl = TextEditingController();
  final TextEditingController _varietyCtrl = TextEditingController();
  final TextEditingController _buyingColorCtrl = TextEditingController();

  // STEP 3 - First Look
  List<String> _firstLookPhotos = [];
  String? _firstLookVideo;

  // STEP 4 - Value Additions
  List<ValueAdditionModel> _valueAdditions = [];

  // STEP 5 - Final Stage
  final TextEditingController _finalWeightCtrl = TextEditingController();
  GemShape _shape = GemShape.faceted;
  final TextEditingController _customShapeCtrl = TextEditingController();
  GemClarity _clarity = GemClarity.vvs1;
  final TextEditingController _finalColorCtrl = TextEditingController();
  InventoryGemStatus _status = InventoryGemStatus.rough;
  final TextEditingController _lengthCtrl = TextEditingController();
  final TextEditingController _widthCtrl = TextEditingController();
  final TextEditingController _depthCtrl = TextEditingController();

  // STEP 6 - Final Media
  List<String> _finalPhotos = [];
  String? _finalVideo;

  // STEP 7 - Certification
  bool _isCertified = false;
  List<CertificateModel> _certificates = [];

  // STEP 8 - Finance & Sales
  final TextEditingController _salesTargetPriceCtrl =
      TextEditingController(text: '0');
  bool _isReadyToSale = false;
  bool _isSold = false;
  final TextEditingController _actualSoldPriceCtrl =
      TextEditingController(text: '0');
  PredictionModel? _prediction;
  bool _isLoadingPrediction = false;
  Timer? _predictionDebounce;

  // Whether the user has changed clarity from its default (we don't want
  // the default 'VVS1' to narrow the initial DB query to zero rows).
  bool _clarityUserSet = false;

  String? _firstLookMediaError;
  String? _finalMediaError;

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
    if (widget.gemstoneToEdit != null) {
      _loadExistingGemstone(widget.gemstoneToEdit!);
      // When editing, treat clarity as user-set so it's included.
      _clarityUserSet = true;
    }
    // Defer until the frame is fully built so Riverpod ref is ready.
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

    // Only pass purchasePrice when user has actually entered a non-zero value.
    final enteredPrice = double.tryParse(_buyingPriceCtrl.text);
    final purchasePrice =
        (enteredPrice != null && enteredPrice > 0) ? enteredPrice : null;

    // Only pass clarity when the user has explicitly changed it from the
    // default; the default 'VVS1' would filter out most historical records.
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
      // Even on error, show the card with a no-data state rather than hiding it.
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

  // ── AI Prediction bottom sheet ─────────────────────────────────────────────
  void _showPredictionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PredictionSheet(
        prediction: _prediction,
        isLoading: _isLoadingPrediction,
        confidenceColor: _confidenceColor,
      ),
    );
  }

  // ── After Buying Details step — ask if user wants AI predictions ───────────
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

  Widget _buildPredictionCard() {
    final confidenceLabel = _prediction?.confidenceLevel ?? 'Low';
    final recordCount = _prediction?.matchingRecordCount ?? 0;
    final hasData = recordCount > 0;

    // Show nothing when not loading and no prediction has been triggered yet
    if (_prediction == null && !_isLoadingPrediction) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(sizeFactor: animation, child: child),
      ),
      child: Card(
        key: ValueKey(
            'prediction_${_isLoadingPrediction ? 'loading' : recordCount}'),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.insights_outlined,
                        size: 20, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '📊 Business Prediction',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Loading state ────────────────────────────────────────────
              if (_isLoadingPrediction) ...[
                const SizedBox(height: 4),
                const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Calculating prediction…',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                const SizedBox(height: 8),
              ] else if (!hasData) ...
                // ── No-data state ─────────────────────────────────────────
                [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'No sufficient historical records available for prediction.',
                          style: TextStyle(fontSize: 12, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...
                // ── Data state ────────────────────────────────────────────
                [
                Text(
                  'Based on $recordCount similar inventory records',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildPredictionMetric(
                  'Expected Selling Price',
                  _prediction!.expectedSellingPrice,
                  icon: Icons.attach_money,
                  isCurrency: true,
                ),
                _buildPredictionMetric(
                  'Expected Expenses',
                  _prediction!.expectedExpenses,
                  icon: Icons.receipt_long,
                  isCurrency: true,
                ),
                _buildPredictionMetric(
                  'Expected Profit',
                  _prediction!.expectedProfit,
                  icon: Icons.trending_up,
                  isCurrency: true,
                  valueColor: _prediction!.expectedProfit >= 0
                      ? AppColors.successGreen
                      : AppColors.accentRed,
                ),
                _buildPredictionMetric(
                  'Expected Selling Time',
                  _prediction!.expectedDaysToSell,
                  icon: Icons.schedule,
                  suffix: ' days',
                  isCurrency: false,
                ),
                _buildPredictionMetric(
                  'Avg. Profit Margin',
                  _prediction!.profitMarginPercent,
                  icon: Icons.percent,
                  suffix: '%',
                  isCurrency: false,
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 16, color: _confidenceColor(confidenceLabel)),
                        const SizedBox(width: 6),
                        const Text('Confidence Level',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _confidenceColor(confidenceLabel)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _confidenceColor(confidenceLabel)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        confidenceLabel,
                        style: TextStyle(
                          color: _confidenceColor(confidenceLabel),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionMetric(
    String label,
    double value, {
    String suffix = '',
    IconData? icon,
    bool isCurrency = true,
    Color? valueColor,
  }) {
    final String displayValue = isCurrency
        ? NumberFormat.currency(locale: 'en_LK', symbol: 'Rs. ')
            .format(value.toInt())
        : '${value.toStringAsFixed(1)}$suffix';

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(List<String> list, int maxPhotos) async {
    if (list.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum $maxPhotos photos allowed.')));
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        list.add(image.path);
      });
    }
  }

  Future<void> _pickVideo(Function(String?) onPicked) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        onPicked(video.path);
      });
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
            return AlertDialog(
              title: const Text('Add Value Addition'),
              content: SingleChildScrollView(
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
                      decoration: const InputDecoration(labelText: 'Cost Type'),
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
                    ),
                    TextFormField(
                      controller: weightCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Current Weight (ct)'),
                      keyboardType: TextInputType.number,
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
                        if (images.length >= 2) return;
                        final img = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (img != null) {
                          setStateDialog(() => images.add(img.path));
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

  void _publishInventoryItem() async {
    if (!_formKey.currentState!.validate()) return;

    final newGem = GemstoneModel(
      id: widget.gemstoneToEdit?.id,
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
            gem: newGem,
            rawFirstLookPhotos: _firstLookPhotos,
            rawFirstLookVideo: _firstLookVideo,
            rawFinalPhotos: _finalPhotos,
            rawFinalVideo: _finalVideo,
          );

      if (mounted) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: validator,
      ),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime date, Function(DateTime) onSelect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (selected != null) onSelect(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          child: Text(DateFormat('yyyy-MM-dd').format(date)),
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      // ── STEP 1: BASIC INFO ──────────────────────────────────────────────────
      Step(
        title: const Text('Basic Info'),
        content: Column(
          children: [
            DropdownButtonFormField<GemCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                  labelText: 'Category *', border: OutlineInputBorder()),
              items: GemCategory.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.displayName)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _category = val!;
                  // Rule: Automatically populate Variety field using Category selection
                  if (_category != GemCategory.other) {
                    _varietyCtrl.text = _category.displayName;
                  } else {
                    _varietyCtrl.text = _customCategoryCtrl.text;
                  }
                });
                _refreshPredictionFromInputs();
              },
            ),
            const SizedBox(height: 16),
            if (_category == GemCategory.other) ...[
              _buildTextField('Custom Category *', _customCategoryCtrl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              initialValue: _origin,
              decoration: const InputDecoration(
                  labelText: 'Origin', border: OutlineInputBorder()),
              items: _origins
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() => _origin = val!);
                _refreshPredictionFromInputs();
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GemVisibility>(
              initialValue: _visibility,
              decoration: const InputDecoration(
                  labelText: 'Visibility', border: OutlineInputBorder()),
              items: GemVisibility.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.displayName)))
                  .toList(),
              onChanged: (val) => setState(() => _visibility = val!),
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
            // Rule: Required, Must be > 0, Cannot be negative/zero
            _buildTextField('Buying Weight (ct) *', _buyingWeightCtrl,
                isNumber: true,
                validator: GemFormValidator.validateBuyingWeight),

            // Rule: Required, Cannot be negative, Greater than zero
            _buildTextField('Buying Price *', _buyingPriceCtrl,
                isNumber: true,
                validator: GemFormValidator.validateBuyingPrice),

            _buildDatePicker('Buying Date', _buyingDate,
                (d) => setState(() => _buyingDate = d)),

            _buildTextField('Buyer Name (Optional)', _buyerNameCtrl),

            // Note: If using a dedicated phone package, replace this field with your international picker
            _buildTextField(
                'Buyer Contact Number (Optional)', _buyerContactCtrl),

            // Rule: Automatically populated from Step 1. Disabled to prevent manual changes.
            TextFormField(
              controller: _varietyCtrl,
              enabled: false, // This cleanly locks the field from manual typing
              decoration: const InputDecoration(
                labelText: 'Variety (Auto-Populated)',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),

            // Rule: Required, Cannot be empty
            _buildTextField('Buying Color *', _buyingColorCtrl,
                validator: GemFormValidator.validateBuyingColor),
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

            // Rule: Dynamic requirement count messaging displayed cleanly to the user
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
            // Rule: Validation checks against previous current baseline weight histories
            _buildTextField('Final Weight (ct) *', _finalWeightCtrl,
                isNumber: true,
                validator: (v) => GemFormValidator.validateFinalWeight(
                    v, _currentBaselineWeight)),

            DropdownButtonFormField<GemShape>(
              initialValue: _shape,
              decoration: const InputDecoration(
                  labelText: 'Shape', border: OutlineInputBorder()),
              items: GemShape.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.displayName)))
                  .toList(),
              onChanged: (val) => setState(() => _shape = val!),
            ),
            const SizedBox(height: 16),
            if (_shape == GemShape.other) ...[
              _buildTextField('Custom Shape', _customShapeCtrl),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<GemClarity>(
              initialValue: _clarity,
              decoration: const InputDecoration(
                  labelText: 'Clarity', border: OutlineInputBorder()),
              items: GemClarity.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.displayName)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _clarity = val!;
                  _clarityUserSet = true;
                });
                _refreshPredictionFromInputs();
              },
            ),
            const SizedBox(height: 16),

            // Rule: Cannot be empty
            _buildTextField('Final Color *', _finalColorCtrl,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Final color is required'
                    : null),

            DropdownButtonFormField<InventoryGemStatus>(
              initialValue: _status,
              decoration: const InputDecoration(
                  labelText: 'Status', border: OutlineInputBorder()),
              items: InventoryGemStatus.values
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.displayName)))
                  .toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),

            // Rule: Length, Width, Depth validation dynamically enforced if Status == Cut
            if (_status == InventoryGemStatus.cut) ...[
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Dimensions (Required for Cut Status) *',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: _buildTextField('Length *', _lengthCtrl,
                          isNumber: true,
                          validator: (v) => GemFormValidator.validateDimension(
                              v, _status.displayName))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildTextField('Width *', _widthCtrl,
                          isNumber: true,
                          validator: (v) => GemFormValidator.validateDimension(
                              v, _status.displayName))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildTextField('Depth *', _depthCtrl,
                          isNumber: true,
                          validator: (v) => GemFormValidator.validateDimension(
                              v, _status.displayName))),
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

            // Rule: Display remaining requirements dynamically to user
            if (_finalMediaError != null) ...[
              const SizedBox(height: 12),
              Text(
                _finalMediaError!,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
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
            _buildPredictionCard(),
            ListTile(
              title: const Text('Total Final Cost'),
              trailing: Text('Rs. ${_totalFinalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _buildTextField('Sales Target Price', _salesTargetPriceCtrl,
                isNumber: true),
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
              _buildTextField('Actual Sold Price', _actualSoldPriceCtrl,
                  isNumber: true),
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

  // === NEW STEP VALIDATOR LOGIC ===
  bool _validateCurrentStep() {
    // Reset display errors cleanly
    setState(() {
      _firstLookMediaError = null;
      _finalMediaError = null;
    });

    switch (_currentStep) {
      case 0: // Basic Information
        // Rule: Automatically populate Variety field using Category selection
        if (_varietyCtrl.text.isEmpty) {
          _varietyCtrl.text = _category == GemCategory.other
              ? _customCategoryCtrl.text
              : _category.displayName;
        }
        return true;

      case 1: // Buying Details
        // Variety verification fallback
        if (_varietyCtrl.text.isEmpty) {
          _varietyCtrl.text = _category == GemCategory.other
              ? _customCategoryCtrl.text
              : _category.displayName;
        }

        // Form field layout runner checking Weight, Price, and Color text controllers
        final isFormValid = _formKey.currentState?.validate() ?? false;
        if (!isFormValid) return false;

        // Clean Contact Number automatically if provided
        if (_buyerContactCtrl.text.isNotEmpty) {
          // Remove spaces, dashes, and keep only clean digits after any formatting
          final cleanDigits =
              _buyerContactCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
          _buyerContactCtrl.text = cleanDigits;
        }
        return true;

      case 2: // First Look Media Check
        final imgCount = _firstLookPhotos.length;
        final hasVid = _firstLookVideo != null;

        // Rule: Require minimum 2 images and 1 video. Display remaining count dynamically.
        if (imgCount < 2 && !hasVid) {
          setState(() => _firstLookMediaError =
              'Please add ${2 - imgCount} more image(s) and 1 video.');
          return false;
        } else if (imgCount < 2) {
          setState(() => _firstLookMediaError =
              'Please add ${2 - imgCount} more image(s).');
          return false;
        } else if (!hasVid) {
          setState(() => _firstLookMediaError = 'Please add 1 video.');
          return false;
        }
        return true;

      case 3: // Value Addition History Check
        return true; // Array additions individually checked during Dialog creation sequence

      case 4: // Final Stage Fields
        // Rule: Auto-populate Final Color from Buying Color if unedited
        if (_finalColorCtrl.text.trim().isEmpty) {
          _finalColorCtrl.text = _buyingColorCtrl.text;
        }

        // Rule: Auto-initialize Final Weight using latest Baseline Weight from Value Additions
        if (_finalWeightCtrl.text.trim().isEmpty) {
          _finalWeightCtrl.text = _currentBaselineWeight.toString();
        }

        return _formKey.currentState?.validate() ?? false;

      case 5: // Final Media Check
        final imgCount = _finalPhotos.length;
        final hasVid = _finalVideo != null;

        // Rule: Enforce minimum 2 images and 1 video before finishing wizard tracking
        if (imgCount < 2 && !hasVid) {
          setState(() => _finalMediaError =
              'Please add ${2 - imgCount} more image(s) and 1 video.');
          return false;
        } else if (imgCount < 2) {
          setState(() =>
              _finalMediaError = 'Please add ${2 - imgCount} more image(s).');
          return false;
        } else if (!hasVid) {
          setState(() => _finalMediaError = 'Please add 1 video.');
          return false;
        }
        return true;

      case 6: // Certification Step Validation
        if (_isCertified && _certificates.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Please add at least one certificate or disable certification.')),
          );
          return false;
        }
        return true;

      default:
        return _formKey.currentState?.validate() ?? false;
    }
  }
  // ================================

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final state = ref.watch(addNewGemstoneViewModelProvider);
    final isLoading = state.isLoading || state.isSuccess;

    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: Text(
              widget.gemstoneToEdit != null ? 'Edit Gemstone' : 'Add Gemstone'),
          centerTitle: true,
          actions: [
            // AI prediction icon — always visible, reopens the sheet
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
                    // ONLY CHANGE: Wrap your original transition code in the validator check
                    if (_validateCurrentStep()) {
                      final steps = _buildSteps();
                      if (_currentStep < steps.length - 1) {
                        setState(() => _currentStep += 1);
                        // After advancing past Buying Details (step index 1),
                        // prompt the user to view AI predictions.
                        if (_currentStep == 2) {
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _showAiPromptDialog());
                        }
                      } else {
                        _publishInventoryItem();
                      }
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

// ─────────────────────────────────────────────────────────────────────────────
// Private bottom-sheet widget for AI Prediction
// Receives data from the parent state; contains no business logic.
// ─────────────────────────────────────────────────────────────────────────────
class _PredictionSheet extends StatelessWidget {
  const _PredictionSheet({
    required this.prediction,
    required this.isLoading,
    required this.confidenceColor,
  });

  final PredictionModel? prediction;
  final bool isLoading;
  final Color Function(String) confidenceColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final recordCount = prediction?.matchingRecordCount ?? 0;
    final hasData = recordCount > 0;
    final confidenceLabel = prediction?.confidenceLevel ?? 'Low';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📊 Business Prediction',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17)),
                        Text('AI-powered market analysis',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            // ── Scrollable content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: _buildContent(
                    context, hasData, recordCount, confidenceLabel, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool hasData, int recordCount,
      String confidenceLabel, bool isDark) {
    // ── Loading ─────────────────────────────────────────────────────────────
    if (isLoading) {
      return Column(
        children: [
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('Analysing historical records…',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      );
    }

    // ── No data ─────────────────────────────────────────────────────────────
    if (!hasData) {
      return Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'No sufficient historical records available for prediction.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, height: 1.6, color: Colors.amber),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add more sold inventory records to improve accuracy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ── Has data ────────────────────────────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Record count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Based on $recordCount similar inventory records',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        // Metric cards
        _metricCard(
          label: 'Expected Selling Price',
          value: prediction!.expectedSellingPrice,
          icon: Icons.attach_money,
          isCurrency: true,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Expected Expenses',
          value: prediction!.expectedExpenses,
          icon: Icons.receipt_long,
          isCurrency: true,
          color: AppColors.accentOrange,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Expected Profit',
          value: prediction!.expectedProfit,
          icon: Icons.trending_up,
          isCurrency: true,
          color: prediction!.expectedProfit >= 0
              ? AppColors.successGreen
              : AppColors.accentRed,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Expected Selling Time',
          value: prediction!.expectedDaysToSell,
          icon: Icons.schedule,
          isCurrency: false,
          suffix: ' days',
          color: AppColors.accentPurple,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Avg. Profit Margin',
          value: prediction!.profitMarginPercent,
          icon: Icons.percent,
          isCurrency: false,
          suffix: '%',
          color: AppColors.primaryYellow,
        ),
        const SizedBox(height: 24),
        // Confidence row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: confidenceColor(confidenceLabel).withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: confidenceColor(confidenceLabel).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: confidenceColor(confidenceLabel), size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Confidence Level',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      confidenceColor(confidenceLabel).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        confidenceColor(confidenceLabel).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  confidenceLabel,
                  style: TextStyle(
                    color: confidenceColor(confidenceLabel),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    bool isCurrency = true,
    String suffix = '',
  }) {
    final displayValue = isCurrency
        ? NumberFormat.currency(locale: 'en_LK', symbol: 'Rs. ')
            .format(value.toInt())
        : '${value.toStringAsFixed(1)}$suffix';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/inventory/media_processing_state.dart';
import 'package:gemhub/data/models/inventory/value_addition_model.dart';
import 'package:gemhub/data/models/inventory/certificate_model.dart';
import 'package:gemhub/core/enums/inventory_enums.dart';
import 'package:gemhub/features/inventory/viewmodels/add_new_gemstone_viewmodel.dart';

class AddNewGemstoneScreen extends ConsumerStatefulWidget {
  final GemstoneModel? gemstoneToEdit;
  const AddNewGemstoneScreen({super.key, this.gemstoneToEdit});

  @override
  ConsumerState<AddNewGemstoneScreen> createState() => _AddNewGemstoneScreenState();
}

class _AddNewGemstoneScreenState extends ConsumerState<AddNewGemstoneScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // STEP 1 - Basic Info
  GemCategory _category = GemCategory.sapphire;
  final TextEditingController _customCategoryCtrl = TextEditingController();
  String _origin = 'Sri Lanka';
  final List<String> _origins = ['Sri Lanka', 'Madagascar', 'Myanmar', 'Tanzania', 'Other'];
  GemVisibility _visibility = GemVisibility.private;

  // STEP 2 - Buying Details
  final TextEditingController _buyingWeightCtrl = TextEditingController();
  final TextEditingController _buyingPriceCtrl = TextEditingController(text: '0');
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
  final TextEditingController _salesTargetPriceCtrl = TextEditingController(text: '0');
  bool _isReadyToSale = false;
  bool _isSold = false;
  final TextEditingController _actualSoldPriceCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    if (widget.gemstoneToEdit != null) {
      _loadExistingGemstone(widget.gemstoneToEdit!);
    }
  }

  void _loadExistingGemstone(GemstoneModel gem) {
    try {
      _category = GemCategory.values.firstWhere((e) => e.displayName == gem.category, orElse: () => GemCategory.other);
    } catch (_) { _category = GemCategory.other; }
    if (_category == GemCategory.other) _customCategoryCtrl.text = gem.category;

    _origin = gem.origin.isNotEmpty ? gem.origin : 'Sri Lanka';
    if (!_origins.contains(_origin)) _origin = 'Other';

    try {
      _visibility = GemVisibility.values.firstWhere((e) => e.displayName == gem.visibility, orElse: () => GemVisibility.private);
    } catch (_) { _visibility = GemVisibility.private; }

    _buyingWeightCtrl.text = gem.buyingWeight.toString();
    _buyingPriceCtrl.text = gem.buyingPrice.toString();
    
    try {
      _recordDate = DateTime.parse(gem.recordDate);
    } catch (_) { _recordDate = DateTime.now(); }
    
    try {
      _buyingDate = DateTime.parse(gem.buyingDate);
    } catch (_) { _buyingDate = DateTime.now(); }

    _buyerNameCtrl.text = gem.buyerName;
    _buyerContactCtrl.text = gem.buyerContact;
    _varietyCtrl.text = gem.variety;
    _buyingColorCtrl.text = gem.buyingColor;

    _firstLookPhotos = List.from(gem.firstLookPhotos);
    _firstLookVideo = gem.firstLookVideo;

    _valueAdditions = List.from(gem.valueAdditions);

    _finalWeightCtrl.text = gem.finalWeight > 0 ? gem.finalWeight.toString() : gem.currentWeight.toString();
    try {
      _shape = GemShape.values.firstWhere((e) => e.displayName == gem.shape, orElse: () => GemShape.other);
    } catch (_) { _shape = GemShape.other; }
    if (_shape == GemShape.other) _customShapeCtrl.text = gem.shape;

    try {
      _clarity = GemClarity.values.firstWhere((e) => e.displayName == gem.clarity, orElse: () => GemClarity.vvs1);
    } catch (_) { _clarity = GemClarity.vvs1; }

    _finalColorCtrl.text = gem.finalColor;
    try {
      _status = InventoryGemStatus.values.firstWhere((e) => e.displayName == gem.status, orElse: () => InventoryGemStatus.rough);
    } catch (_) { _status = gem.isCut ? InventoryGemStatus.cut : InventoryGemStatus.rough; }

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

  double get _totalValueAdditionCosts => _valueAdditions.fold(0.0, (sum, addition) => sum + addition.cost);
  double get _totalCertificateFees => _certificates.fold(0.0, (sum, cert) => sum + cert.certificateFees);
  
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
    return (salesTarget > 0 && _totalFinalCost > 0) ? (_targetProfit / _totalFinalCost) * 100 : 0.0;
  }

  double get _actualProfit {
    double actualSold = double.tryParse(_actualSoldPriceCtrl.text) ?? 0;
    return (_isSold && actualSold > 0) ? (actualSold - _totalFinalCost) : 0;
  }

  double get _actualMargin {
    return (_isSold && _totalFinalCost > 0) ? (_actualProfit / _totalFinalCost) * 100 : 0.0;
  }

  double get _currentWeight {
    if (_valueAdditions.isNotEmpty) {
      return _valueAdditions.last.currentWeight;
    }
    return double.tryParse(_buyingWeightCtrl.text) ?? 0.0;
  }

  Future<void> _pickImage(List<String> list, int maxPhotos) async {
    if (list.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Maximum $maxPhotos photos allowed.')));
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
        final weightCtrl = TextEditingController(text: _currentWeight.toString());
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
                      items: CostType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
                      onChanged: (val) => setStateDialog(() => type = val!),
                      decoration: const InputDecoration(labelText: 'Cost Type'),
                    ),
                    if (type == CostType.treatment)
                      TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Treatment Name')),
                    if (type == CostType.other)
                      TextFormField(controller: reasonCtrl, decoration: const InputDecoration(labelText: 'Reason')),
                    TextFormField(
                      controller: costCtrl,
                      decoration: const InputDecoration(labelText: 'Cost'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: weightCtrl,
                      decoration: const InputDecoration(labelText: 'Current Weight (ct)'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
                    TextFormField(controller: labCtrl, decoration: const InputDecoration(labelText: 'Lab Name')),
                    TextFormField(
                      controller: feeCtrl,
                      decoration: const InputDecoration(labelText: 'Certificate Fees'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        if (images.length >= 2) return;
                        final img = await _picker.pickImage(source: ImageSource.gallery);
                        if (img != null) setStateDialog(() => images.add(img.path));
                      },
                      child: Text('Add Image (${images.length}/2)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
      category: _category == GemCategory.other ? _customCategoryCtrl.text : _category.displayName,
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
      shape: _shape == GemShape.other ? _customShapeCtrl.text : _shape.displayName,
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, String? Function(String?)? validator}) {
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

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onSelect) {
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
      Step(
        title: const Text('Basic Info'),
        content: Column(
          children: [
            DropdownButtonFormField<GemCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: GemCategory.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),
            if (_category == GemCategory.other) _buildTextField('Custom Category', _customCategoryCtrl),
            DropdownButtonFormField<String>(
              initialValue: _origin,
              decoration: const InputDecoration(labelText: 'Origin', border: OutlineInputBorder()),
              items: _origins.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _origin = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<GemVisibility>(
              initialValue: _visibility,
              decoration: const InputDecoration(labelText: 'Visibility', border: OutlineInputBorder()),
              items: GemVisibility.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
              onChanged: (val) => setState(() => _visibility = val!),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Buying Details'),
        content: Column(
          children: [
            _buildTextField('Buying Weight (ct)', _buyingWeightCtrl, isNumber: true, validator: (v) => v!.isEmpty ? 'Required' : null),
            _buildTextField('Buying Price', _buyingPriceCtrl, isNumber: true, validator: (v) => v!.isEmpty ? 'Required' : null),
            _buildDatePicker('Buying Date', _buyingDate, (d) => setState(() => _buyingDate = d)),
            _buildTextField('Buyer Name', _buyerNameCtrl),
            _buildTextField('Buyer Contact Number', _buyerContactCtrl),
            _buildTextField('Variety', _varietyCtrl),
            _buildTextField('Buying Color', _buyingColorCtrl),
          ],
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
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
              children: _firstLookPhotos.map((path) => Chip(
                label: const Text('Photo'),
                onDeleted: () => setState(() => _firstLookPhotos.remove(path)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickVideo((path) => _firstLookVideo = path),
              child: Text(_firstLookVideo != null ? 'Change Video' : 'Add Video'),
            ),
          ],
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
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
                    onPressed: () => setState(() => _valueAdditions.removeAt(index)),
                  ),
                );
              },
            ),
          ],
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Final Stage'),
        content: Column(
          children: [
            _buildTextField('Final Weight (ct)', _finalWeightCtrl, isNumber: true),
            DropdownButtonFormField<GemShape>(
              initialValue: _shape,
              decoration: const InputDecoration(labelText: 'Shape', border: OutlineInputBorder()),
              items: GemShape.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
              onChanged: (val) => setState(() => _shape = val!),
            ),
            const SizedBox(height: 16),
            if (_shape == GemShape.other) _buildTextField('Custom Shape', _customShapeCtrl),
            DropdownButtonFormField<GemClarity>(
              initialValue: _clarity,
              decoration: const InputDecoration(labelText: 'Clarity', border: OutlineInputBorder()),
              items: GemClarity.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
              onChanged: (val) => setState(() => _clarity = val!),
            ),
            const SizedBox(height: 16),
            _buildTextField('Final Color', _finalColorCtrl),
            DropdownButtonFormField<InventoryGemStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: InventoryGemStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
              onChanged: (val) => setState(() => _status = val!),
            ),
            if (_status == InventoryGemStatus.cut) ...[
              const SizedBox(height: 16),
              const Text('Dimensions', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: _buildTextField('Length', _lengthCtrl, isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField('Width', _widthCtrl, isNumber: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField('Depth', _depthCtrl, isNumber: true)),
                ],
              ),
            ]
          ],
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
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
              children: _finalPhotos.map((path) => Chip(
                label: const Text('Photo'),
                onDeleted: () => setState(() => _finalPhotos.remove(path)),
              )).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickVideo((path) => _finalVideo = path),
              child: Text(_finalVideo != null ? 'Change Final Video' : 'Add Final Video'),
            ),
          ],
        ),
        isActive: _currentStep >= 5,
        state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      ),
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
                      onPressed: () => setState(() => _certificates.removeAt(index)),
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
      Step(
        title: const Text('Finance & Sales'),
        content: Column(
          children: [
            ListTile(
              title: const Text('Total Final Cost'),
              trailing: Text('Rs. ${_totalFinalCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            _buildTextField('Sales Target Price', _salesTargetPriceCtrl, isNumber: true),
            ListTile(
              title: const Text('Target Profit / Margin'),
              trailing: Text('Rs. ${_targetProfit.toStringAsFixed(2)} / ${_targetMargin.toStringAsFixed(2)}%'),
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
              _buildTextField('Actual Sold Price', _actualSoldPriceCtrl, isNumber: true),
              ListTile(
                title: const Text('Actual Profit / Margin'),
                trailing: Text('Rs. ${_actualProfit.toStringAsFixed(2)} / ${_actualMargin.toStringAsFixed(2)}%'),
              ),
            ]
          ],
        ),
        isActive: _currentStep >= 7,
        state: StepState.indexed,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final state = ref.watch(addNewGemstoneViewModelProvider);
    final isLoading = state.isLoading || state.isSuccess;

    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          title: Text(widget.gemstoneToEdit != null ? 'Edit Gemstone' : 'Add Gemstone'),
          centerTitle: true,
        ),
        body: isLoading 
          ? Center(child: CircularProgressIndicator(value: state.progress))
          : Form(
              key: _formKey,
              child: Stepper(
                physics: const ClampingScrollPhysics(),
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < _buildSteps().length - 1) {
                    setState(() => _currentStep += 1);
                  } else {
                    _publishInventoryItem();
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primaryYellow,
                            ),
                            child: Text(_currentStep == _buildSteps().length - 1 ? 'PUBLISH' : 'NEXT', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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

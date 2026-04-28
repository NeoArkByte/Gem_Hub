import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/core/enums/gem_status.dart';
import 'package:job_market/core/enums/gem_type.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/features/gem_market/viewmodel/gem_marketplace_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Light theme tokens ────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF10C971);
  static const accentLight = Color(0xFFDCFCE7);
  static const text = Color(0xFF111827);
  static const subText = Color(0xFF6B7280);
}

class AddGemScreen extends ConsumerStatefulWidget {
  const AddGemScreen({super.key});

  @override
  ConsumerState<AddGemScreen> createState() => _AddGemScreenState();
}

class _AddGemScreenState extends ConsumerState<AddGemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _caratController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _colorController = TextEditingController();
  final _clarityController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _shapeController = TextEditingController();
  final _originController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isPublishing = false;

  GemType _selectedType = GemType.sapphire;

  @override
  void dispose() {
    _nameController.dispose();
    _caratController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _colorController.dispose();
    _clarityController.dispose();
    _treatmentController.dispose();
    _shapeController.dispose();
    _originController.dispose();
    _sellerPhoneController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      appBar: AppBar(
        backgroundColor: _T.card,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _T.text),
        title: const Text(
          'List New Gem',
          style: TextStyle(
            color: _T.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _T.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUploadArea(),
              const SizedBox(height: 24),
              _sectionLabel('Gem Details'),
              const SizedBox(height: 12),
              _buildTextField('Gem Name', 'e.g. Royal Blue Sapphire', Icons.diamond_outlined, _nameController),
              _buildDropdownField('Gem Type', Icons.category_outlined),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Carat Weight',
                      'e.g. 2.5',
                      Icons.scale_outlined,
                      _caratController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      'Price (USD)',
                      'e.g. 1200',
                      Icons.attach_money_rounded,
                      _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Color', 'e.g. Vivid Blue', Icons.palette_outlined, _colorController),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField('Shape', 'e.g. Oval', Icons.shape_line_outlined, _shapeController),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Clarity', 'e.g. VVS1', Icons.remove_red_eye_outlined, _clarityController),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField('Treatment', 'e.g. Heat', Icons.wb_sunny_outlined, _treatmentController),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Origin', 'e.g. Ceylon', Icons.location_on_outlined, _originController),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField('Location', 'e.g. Colombo', Icons.map_outlined, _locationController),
                  ),
                ],
              ),
              _buildTextField(
                'Description',
                'Describe the gem\'s quality, clarity, and history...',
                Icons.notes_rounded,
                _descController,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _sectionLabel('Contact & Media (Optional)'),
              const SizedBox(height: 12),
              _buildTextField('Seller Phone', 'e.g. +1 234 567 8900', Icons.phone_outlined, _sellerPhoneController, isOptional: true),
              _buildTextField('Image URL', 'e.g. https://...', Icons.image_outlined, _imageUrlController),
              _buildVideoUploadArea(),
              const SizedBox(height: 28),
              _buildPublishButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: _T.subText,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildImageUploadArea() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _T.accentLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _T.accent.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _T.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_a_photo_outlined,
              size: 26,
              color: _T.accent,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Upload Gem Photos',
            style: TextStyle(
              color: _T.accent,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'JPG, PNG up to 10MB',
            style: TextStyle(color: _T.subText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoUploadArea() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _T.border,
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _T.subText.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library_outlined,
              size: 22,
              color: _T.subText,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload 360° Video (Optional)',
            style: TextStyle(
              color: _T.text,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'MP4, MOV up to 50MB',
            style: TextStyle(color: _T.subText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<GemType>(
        value: _selectedType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _T.subText, fontSize: 13),
          prefixIcon: Icon(icon, color: _T.subText, size: 18),
          filled: true,
          fillColor: _T.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _T.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _T.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _T.accent, width: 1.5),
          ),
        ),
        items: GemType.values
            .where((t) => t != GemType.allGems)
            .map(
              (type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName, style: const TextStyle(color: _T.text, fontSize: 14)),
              ),
            )
            .toList(),
        onChanged: (val) {
          if (val != null) setState(() => _selectedType = val);
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: _T.text, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: _T.subText, fontSize: 13),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
          prefixIcon: Icon(icon, color: _T.subText, size: 18),
          filled: true,
          fillColor: _T.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _T.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _T.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _T.accent, width: 1.5),
          ),
        ),
        validator: isOptional ? null : (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _buildPublishButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isPublishing ? null : _handlePublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: _T.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: _isPublishing 
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Icon(Icons.publish_rounded, size: 20),
        label: Text(
          _isPublishing ? 'Publishing...' : 'Publish Listing',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final ownerId = prefs.getString('logged_in_user_id') ?? 'anonymous';

      final gem = Gem(
        ownerId: ownerId,
        name: _nameController.text,
        type: _selectedType,
        carat: double.tryParse(_caratController.text) ?? 0,
        price: double.tryParse(_priceController.text) ?? 0,
        description: _descController.text,
        color: _colorController.text,
        clarity: _clarityController.text,
        treatment: _treatmentController.text,
        shape: _shapeController.text,
        origin: _originController.text,
        location: _locationController.text,
        imageUrl: _imageUrlController.text.isNotEmpty 
          ? _imageUrlController.text 
          : 'https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=700', // Default image
        sellerPhone: _sellerPhoneController.text,
        status: GemStatus.active,
        createdAt: DateTime.now().toIso8601String(),
      );

      final success = await ref.read(gemMarketplaceViewModelProvider.notifier).addGem(gem);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gem listed successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to list gem. Please try again.')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }
}

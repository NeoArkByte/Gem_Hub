import 'package:flutter/material.dart';
import 'package:job_market/core/enums/gem_type.dart';

// ─── Light theme tokens ────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF2563EB);
  static const accentLight = Color(0xFFEFF6FF);
  static const text = Color(0xFF111827);
  static const subText = Color(0xFF6B7280);
}

class AddGemScreen extends StatefulWidget {
  const AddGemScreen({super.key});

  @override
  State<AddGemScreen> createState() => _AddGemScreenState();
}

class _AddGemScreenState extends State<AddGemScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _caratController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _colorController = TextEditingController();
  final _originController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _locationController = TextEditingController();

  GemType _selectedType = GemType.sapphire;

  @override
  void dispose() {
    _nameController.dispose();
    _caratController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _colorController.dispose();
    _originController.dispose();
    _sellerPhoneController.dispose();
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
                    child: _buildTextField('Origin', 'e.g. Ceylon', Icons.location_on_outlined, _originController),
                  ),
                ],
              ),
              _buildTextField('Location', 'e.g. Mayfair, London, UK', Icons.map_outlined, _locationController),
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
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Form is valid. You would dispatch this data to your ViewModel here.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Data')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _T.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.publish_rounded, size: 20),
        label: const Text(
          'Publish Listing',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

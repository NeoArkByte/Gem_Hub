import 'package:flutter/material.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/core/enums/gem_type.dart';

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

class UpdateGemScreen extends StatefulWidget {
  final Gem gem;
  const UpdateGemScreen({super.key, required this.gem});

  @override
  State<UpdateGemScreen> createState() => _UpdateGemScreenState();
}

class _UpdateGemScreenState extends State<UpdateGemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _caratController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _colorController;
  late TextEditingController _originController;
  late TextEditingController _locationController;
  late TextEditingController _sellerPhoneController;
  late TextEditingController _videoUrlController;

  late GemType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gem.name);
    _caratController = TextEditingController(text: widget.gem.carat.toString());
    _priceController = TextEditingController(text: widget.gem.price.toString());
    _descController = TextEditingController(text: widget.gem.description);
    _colorController = TextEditingController(text: widget.gem.color);
    _originController = TextEditingController(text: widget.gem.origin);
    _locationController = TextEditingController(text: widget.gem.location);
    _sellerPhoneController = TextEditingController(text: widget.gem.sellerPhone);
    _videoUrlController = TextEditingController(text: widget.gem.videoUrl ?? '');
    
    _selectedType = widget.gem.type == GemType.allGems ? GemType.other : widget.gem.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caratController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _colorController.dispose();
    _originController.dispose();
    _locationController.dispose();
    _sellerPhoneController.dispose();
    _videoUrlController.dispose();
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
          'Edit Gem Details',
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
              _buildTextField('Gem Name', _nameController, Icons.diamond_outlined),
              _buildDropdownField('Gem Type', Icons.category_outlined),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Carat Weight',
                      _caratController,
                      Icons.scale_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      'Price (USD)',
                      _priceController,
                      Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Color', _colorController, Icons.palette_outlined),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField('Origin', _originController, Icons.location_on_outlined),
                  ),
                ],
              ),
              _buildTextField('Location', _locationController, Icons.map_outlined),
              _buildTextField(
                'Description',
                _descController,
                Icons.notes_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _sectionLabel('Contact & Media (Optional)'),
              const SizedBox(height: 12),
              _buildTextField('Seller Phone', _sellerPhoneController, Icons.phone_outlined, isOptional: true),
              _buildVideoUploadArea(),
              const SizedBox(height: 28),
              _buildSaveButton(),
              const SizedBox(height: 12),
              _buildCancelButton(context),
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
            'Update Gem Photos',
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
            'Update 360° Video (Optional)',
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
    TextEditingController controller,
    IconData icon, {
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context);
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
        icon: const Icon(Icons.save_rounded, size: 20),
        label: const Text(
          'Save Changes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: _T.subText,
          side: const BorderSide(color: _T.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// ─── Light theme tokens ────────────────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const accent = Color(0xFF2563EB);
  static const text = Color(0xFF111827);
  static const subText = Color(0xFF6B7280);
}

class UpdateGemScreen extends StatefulWidget {
  final Map<String, dynamic> gemData;
  const UpdateGemScreen({super.key, required this.gemData});

  @override
  State<UpdateGemScreen> createState() => _UpdateGemScreenState();
}

class _UpdateGemScreenState extends State<UpdateGemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _weightController;
  late TextEditingController _originController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.gemData['name']?.toString() ?? '');
    _priceController = TextEditingController(
        text: widget.gemData['price']?.toString() ?? '');
    _weightController = TextEditingController(
        text: widget.gemData['weight']?.toString() ?? '');
    _originController = TextEditingController(
        text: widget.gemData['origin']?.toString() ?? '');
    _descController = TextEditingController(
        text: widget.gemData['description']?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _weightController.dispose();
    _originController.dispose();
    _descController.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Gem Details'),
            const SizedBox(height: 12),
            _buildTextField('Gem Name', _nameController, Icons.diamond_outlined),
            _buildTextField(
              'Price (USD)',
              _priceController,
              Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
            ),
            _buildTextField('Carat Weight', _weightController, Icons.scale_outlined),
            _buildTextField('Origin', _originController, Icons.location_on_outlined),
            _buildTextField(
              'Description',
              _descController,
              Icons.notes_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            _buildSaveButton(),
            const SizedBox(height: 12),
            _buildCancelButton(context),
            const SizedBox(height: 20),
          ],
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
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

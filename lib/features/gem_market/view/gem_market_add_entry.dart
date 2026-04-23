import 'package:flutter/material.dart';

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

class AddGemScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  AddGemScreen({super.key});

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
              _buildTextField('Gem Name', 'e.g. Blue Sapphire', Icons.diamond_outlined),
              _buildTextField(
                'Price (USD)',
                'e.g. 1200',
                Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
              ),
              _buildTextField('Carat Weight', 'e.g. 2.5', Icons.scale_outlined),
              _buildTextField('Origin', 'e.g. Sri Lanka', Icons.location_on_outlined),
              _buildTextField(
                'Description',
                'Describe the gem\'s quality, clarity, and history...',
                Icons.notes_rounded,
                maxLines: 4,
              ),
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

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
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
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
            // Handle submission
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

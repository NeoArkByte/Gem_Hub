import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure you have intl: ^0.18.1 or ^0.19.0 in pubspec.yaml

class AddNewGemstoneScreen extends StatefulWidget {
  const AddNewGemstoneScreen({super.key});

  @override
  State<AddNewGemstoneScreen> createState() => _AddNewGemstoneScreenState();
}

class _AddNewGemstoneScreenState extends State<AddNewGemstoneScreen> {
  // Use a Primary Yellow color consistent with your app's theme
  final Color primaryYellow = const Color(0xFFFDB913);

  // --- 1. Map Excel Columns to State Variables & Controllers ---

  // Date (First column in Excel)
  final TextEditingController _dateCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Stone Details (Excel: 'Variety & Colour')
  String _selectedVariety = 'Sapphire'; // Forces standard input via Dropdown
  final List<String> _varieties = ['Sapphire', 'Ruby', 'Emerald', 'Spinel', 'Tourmaline', 'Chrysoberyl', 'Alexandrite', 'Other'];
  final TextEditingController _colorCtrl = TextEditingController();

  // Buying State (Excel: 'Buying State' Checkboxes)
  bool _isRough = true;
  bool _isCut = false;

  // Buying Metrics (Excel: 'Buying Weight', 'Buying Price')
  final TextEditingController _buyingWeightCtrl = TextEditingController();
  final TextEditingController _buyingPriceCtrl = TextEditingController();

  // Value Addition (Excel: 'Treatment', 'Ability to Recut')
  final TextEditingController _treatmentCtrl = TextEditingController();
  final TextEditingController _abilityToRecutCtrl = TextEditingController();

  // Carat Weight after Value Addition (Excel column: 'Carat Weight after Value Addition')
  final TextEditingController _finalWeightCtrl = TextEditingController();

  // Financials (Excel: 'Total Final Expenses', 'Target Price')
  final TextEditingController _finalExpensesCtrl = TextEditingController();
  final TextEditingController _targetPriceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default date to today
    _dateCtrl.text = DateFormat('yyyy.MM.dd').format(_selectedDate);
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _dateCtrl.dispose();
    _colorCtrl.dispose();
    _buyingWeightCtrl.dispose();
    _buyingPriceCtrl.dispose();
    _treatmentCtrl.dispose();
    _abilityToRecutCtrl.dispose();
    _finalWeightCtrl.dispose();
    _finalExpensesCtrl.dispose();
    _targetPriceCtrl.dispose();
    super.dispose();
  }

  // --- Date Picker Function ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (context, child) {
          return Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primaryYellow)), child: child!);
        });
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('yyyy.MM.dd').format(_selectedDate); // Exact format used in Excel
      });
    }
  }

  // --- The Main Publish Function (Integrate Riverpod later) ---
  void _publishInventoryItem() {
    // TODO: VALIDATIONS (Ensure mandatory fields like buying price are filled)

    // Example map structure for database submission (matching database schema from your DatabaseHelper)
    final gemstoneRecord = {
      'created_at': _dateCtrl.text, // Match Excel 'Date'
      'name': '$_selectedVariety • ${_colorCtrl.text}', // Combination based on Excel details
      'type': _selectedVariety,
      'carat': double.tryParse(_buyingWeightCtrl.text) ?? 0.0,
      'price': double.tryParse(_buyingPriceCtrl.text) ?? 0.0,
      'description': 'Treatment: ${_treatmentCtrl.text} • Ability: ${_abilityToRecutCtrl.text}',
      'status': _isRough ? 'Rough' : 'Cut', // Simplified based on primary buying state
      // TODO: Add fields to DatabaseHelper schema to support Final Weight, Expenses, Target Price etc.
    };

    // TODO: Call Riverpod ViewModel method to insert this map into local DB
    // e.g., ref.read(gemViewModelProvider.notifier).addNewGem(gemstoneRecord);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventory Item Recorded locally 🎉')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8F9FA);
    Color textColor = isDark ? Colors.white : const Color(0xFF111827);
    Color dividerColor = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    final divider = Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Divider(color: dividerColor, thickness: 1));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.close, color: primaryYellow, size: 28), onPressed: () => Navigator.pop(context)),
        title: Text('Add Gem to Inventory', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Divider(color: dividerColor, height: 1, thickness: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group 1: General Info (Mapping Excel column: Date)
                  _buildSectionHeader(Icons.calendar_month, 'RECORD DATE', primaryYellow),
                  const SizedBox(height: 16),
                  _buildDatePickerTextField(isDark),
                  divider,

                  // Group 2: The Stone Details (Mapping Excel columns: Variety & Colour, Buying State)
                  _buildSectionHeader(Icons.diamond_outlined, 'STONE DETAILS', primaryYellow),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildVarietyDropdown(isDark, textColor, dividerColor)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(label: 'Color/Varietial', hint: 'e.g. Royal Blue', controller: _colorCtrl)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Grouping the two boolean columns 'Rough' and 'Cut' into explicit checkbox options
                  _buildBuyingStateSelectors(textColor),
                  divider,

                  // Group 3: Buying Metrics (Mapping Excel columns: Buying Weight (ct), Buying Price)
                  _buildSectionHeader(Icons.shopping_bag_outlined, 'ACQUISITION METRICS', primaryYellow),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(label: 'Buying Weight (ct)', hint: 'e.g. 5.10', controller: _buyingWeightCtrl, keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(label: 'Buying Price (Rs)', hint: 'e.g. 50,000', controller: _buyingPriceCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.currency_rupee)),
                    ],
                  ),
                  divider,

                  // Group 4: Processing (Mapping Excel columns: Value Addition, Carat Weight after)
                  _buildSectionHeader(Icons.precision_manufacturing_outlined, 'PROCESSING DETAILS', primaryYellow),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'Treatment Status', hint: 'e.g. Unheated, Heat only', controller: _treatmentCtrl),
                  const SizedBox(height: 20),
                  _buildTextField(label: 'Recut Ability Notes', hint: 'e.g. Good symmetry', controller: _abilityToRecutCtrl, maxLines: 2),
                  const SizedBox(height: 20),
                  _buildTextField(label: 'Carat Weight After processing', hint: 'e.g. 1.03 (ct)', controller: _finalWeightCtrl, keyboardType: TextInputType.number, suffixText: 'ct'),
                  divider,

                  // Group 5: Advanced Financials (Mapping Excel columns: Total Final Expenses, Target Price)
                  _buildSectionHeader(Icons.query_stats, 'FINANCIAL TARGETS (Optional)', primaryYellow),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(label: 'Tot Expenses (Inc Bought)', hint: 'e.g. 56,000', controller: _finalExpensesCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.payments_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(label: 'Target Sell Price', hint: 'e.g. 150,000', controller: _targetPriceCtrl, keyboardType: TextInputType.number, prefixIcon: Icons.ads_click)),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Persistent Bottom Action Button (publish job connection from before)
          _buildBottomAction(context, bgColor, primaryYellow),
        ],
      ),
    );
  }

  // --- Custom Section Header Widget ---
  Widget _buildSectionHeader(IconData icon, String title, Color primaryYellow) {
    return Row(
      children: [
        Icon(icon, color: primaryYellow, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1)),
      ],
    );
  }

  // --- Text Field Builder Widget (Matches previous UI style) ---
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    int maxLines = 1,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white, // Matches previous screen design
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryYellow, size: 18) : null,
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryYellow, width: 2)),
          ),
        ),
      ],
    );
  }

  // --- Custom Date Picker Text Field ---
  Widget _buildDatePickerTextField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acquisition/Record Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: _dateCtrl,
          readOnly: true, // Prevents keyboard input
          onTap: () => _selectDate(context),
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(Icons.event_note, color: primaryYellow),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryYellow, width: 2)),
          ),
        ),
      ],
    );
  }

  // --- Variety Dropdown Builder (Matches JobCategory design) ---
  Widget _buildVarietyDropdown(bool isDark, Color textColor, Color dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Stone Variety', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVariety,
          dropdownColor: Colors.white,
          style: TextStyle(color: textColor, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: dividerColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primaryYellow, width: 2)),
          ),
          items: _varieties.map((String variety) => DropdownMenuItem<String>(value: variety, child: Text(variety))).toList(),
          onChanged: (String? newValue) => setState(() => _selectedVariety = newValue!),
        ),
      ],
    );
  }

  // --- Conversion of Excel Boolean Columns to Selection Options ---
  Widget _buildBuyingStateSelectors(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Buying State', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
        Row(
          children: [
            Checkbox(value: _isRough, onChanged: (val) => setState(() => _isRough = val!)),
            Text('Rough', style: TextStyle(color: textColor)),
            const SizedBox(width: 32),
            Checkbox(value: _isCut, onChanged: (val) => setState(() => _isCut = val!)),
            Text('Cut', style: TextStyle(color: textColor)),
          ],
        ),
      ],
    );
  }

  // --- Bottom Action Button (Reusable Component pattern used in PostJobScreen) ---
  Widget _buildBottomAction(BuildContext context, Color bgColor, Color primaryYellow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: bgColor, border: const Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            // --- CONNECT THIS PUSH BUTTON TO Riverpod later ---
            onPressed: _publishInventoryItem,
            style: ElevatedButton.styleFrom(backgroundColor: primaryYellow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Add Gem to Inventory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ),
      ),
    );
  }
}
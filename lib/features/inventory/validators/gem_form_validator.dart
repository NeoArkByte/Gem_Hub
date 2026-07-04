// lib/features/inventory/validators/gem_form_validator.dart
class GemFormValidator {
  // --- Step 2 Validation Rules ---
  static String? validateBuyingWeight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Buying weight is required';
    final weight = double.tryParse(value);
    if (weight == null) return 'Enter a valid number';
    if (weight <= 0) return 'Weight must be greater than 0';
    return null;
  }

  static String? validateBuyingPrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Buying price is required';
    final price = double.tryParse(value);
    if (price == null) return 'Enter a valid number';
    if (price <= 0) return 'Buying price must be greater than 0';
    return null;
  }

  static String? validateBuyingColor(String? value) {
    if (value == null || value.trim().isEmpty) return 'Buying color is required';
    return null;
  }

  // --- Step 4 Value Addition Rule ---
  static String? validateValueAdditionCost(String? value) {
    if (value == null || value.trim().isEmpty) return 'Cost is required';
    final cost = double.tryParse(value);
    if (cost == null) return 'Enter a valid number';
    if (cost < 0) return 'Cost cannot be negative';
    return null;
  }

  static String? validateValueAdditionWeight(String? value, double previousWeight) {
    if (value == null || value.trim().isEmpty) return 'Current weight is required';
    final weight = double.tryParse(value);
    if (weight == null) return 'Enter a valid number';
    if (weight < previousWeight) {
      return 'Weight cannot decrease! Must be ≥ ${previousWeight.toStringAsFixed(2)} ct';
    }
    return null;
  }

  // --- Step 5 Final Stage Rules ---
  static String? validateFinalWeight(String? value, double baselineWeight) {
    if (value == null || value.trim().isEmpty) return 'Final weight is required';
    final weight = double.tryParse(value);
    if (weight == null) return 'Enter a valid number';
    if (weight < baselineWeight) {
      return 'Weight cannot be less than previous stage (${baselineWeight.toStringAsFixed(2)} ct)';
    }
    return null;
  }

  static String? validateDimension(String? value, String currentStatus) {
    // Dimensions required only if Status is explicitly "Cut"
    final cleanStatus = currentStatus.trim().toLowerCase();
    final isRequired = cleanStatus == 'cut';
    
    if (!isRequired) {
      if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
        return 'Invalid number';
      }
      return null; // Optional otherwise
    }

    if (value == null || value.trim().isEmpty) return 'Required';
    final dimensionVal = double.tryParse(value);
    if (dimensionVal == null) return 'Invalid number';
    if (dimensionVal <= 0) return 'Must be greater than 0';
    return null;
  }

  // --- Step 7 Certificate Rules ---
  static String? validateLabName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Lab name is required';
    return null;
  }

  static String? validateCertificateFee(String? value) {
    if (value == null || value.trim().isEmpty) return 'Certificate fee is required';
    final fee = double.tryParse(value);
    if (fee == null) return 'Enter a valid number';
    if (fee <= 0) return 'Fee must be greater than zero';
    return null;
  }
}
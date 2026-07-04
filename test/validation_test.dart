import 'package:flutter_test/flutter_test.dart';

// Helper functions matching the implementation in AddGemScreen and UpdateGemScreen
String? validateSellerPhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final cleanVal = value.replaceAll(RegExp(r'[\s\-()]'), '');
  final slRegex = RegExp(r'^(?:\+94|94|0)?[1-9]\d{8}$');
  if (!slRegex.hasMatch(cleanVal)) {
    return 'Enter a valid Sri Lankan number';
  }
  return null;
}

String? validateCarat(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter carat weight';
  }
  final carat = double.tryParse(value.trim());
  if (carat == null || carat <= 0) {
    return 'Enter a valid weight > 0';
  }
  return null;
}

String? validatePrice(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter a price';
  }
  final price = double.tryParse(value.trim());
  if (price == null || price <= 0) {
    return 'Enter a valid price > 0';
  }
  return null;
}

void main() {
  group('Sri Lankan Phone Number Validation Tests', () {
    test('Valid Sri Lankan Mobile Numbers', () {
      expect(validateSellerPhone('0771234567'), isNull);
      expect(validateSellerPhone('+94 77 123 4567'), isNull);
      expect(validateSellerPhone('9477-1234567'), isNull);
      expect(validateSellerPhone('(077) 1234567'), isNull);
      expect(validateSellerPhone('+94771234567'), isNull);
      expect(validateSellerPhone('771234567'), isNull); // optional prefix
    });

    test('Valid Sri Lankan Landline Numbers', () {
      expect(validateSellerPhone('0112223333'), isNull);
      expect(validateSellerPhone('+94 11 222 3333'), isNull);
      expect(validateSellerPhone('0811234567'), isNull);
    });

    test('Invalid Sri Lankan Phone Numbers', () {
      expect(validateSellerPhone('12345678'), isNotNull); // Too short
      expect(validateSellerPhone('077123456'),
          isNotNull); // Too short after prefix
      expect(validateSellerPhone('+947712345678'), isNotNull); // Too long
      expect(validateSellerPhone('+96771234567'),
          isNotNull); // Non-SriLankan code (96 instead of 94)
      expect(validateSellerPhone('077123abcd'), isNotNull); // Non-numeric
    });

    test('Empty or Null is Valid (Optional Field)', () {
      expect(validateSellerPhone(null), isNull);
      expect(validateSellerPhone(''), isNull);
      expect(validateSellerPhone('   '), isNull);
    });
  });

  group('Carat Weight Validation Tests', () {
    test('Valid Carat Weight Values', () {
      expect(validateCarat('2.5'), isNull);
      expect(validateCarat('0.8'), isNull);
      expect(validateCarat('10'), isNull);
    });

    test('Invalid Carat Weight Values', () {
      expect(validateCarat(''), isNotNull);
      expect(validateCarat('  '), isNotNull);
      expect(validateCarat(null), isNotNull);
      expect(validateCarat('0'), isNotNull);
      expect(validateCarat('-1.5'), isNotNull);
      expect(validateCarat('abc'), isNotNull);
    });
  });

  group('Price Validation Tests', () {
    test('Valid Price Values', () {
      expect(validatePrice('150000'), isNull);
      expect(validatePrice('2000.50'), isNull);
      expect(validatePrice('50'), isNull);
    });

    test('Invalid Price Values', () {
      expect(validatePrice(''), isNotNull);
      expect(validatePrice('  '), isNotNull);
      expect(validatePrice(null), isNotNull);
      expect(validatePrice('0'), isNotNull);
      expect(validatePrice('-500'), isNotNull);
      expect(validatePrice('abc'), isNotNull);
    });
  });
}

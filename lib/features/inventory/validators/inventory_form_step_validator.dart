import 'package:flutter/material.dart';
import 'package:gemhub/core/enums/inventory_enums.dart';
import 'package:gemhub/data/models/inventory/certificate_model.dart';

/// Holds the validation outcome for a form step, including an optional error message.
class InventoryFormStepValidatorResult {
  final bool isValid;
  final String? errorMessage;

  const InventoryFormStepValidatorResult({
    required this.isValid,
    this.errorMessage,
  });
}

/// Centralized validator for inventory entry form steps (Add / Update).
class InventoryFormStepValidator {
  /// Validates step-by-step form progression for Add and Update entry screens.
  static InventoryFormStepValidatorResult validateStep({
    required int step,
    required GemCategory category,
    required TextEditingController varietyCtrl,
    required TextEditingController customCategoryCtrl,
    required TextEditingController buyingWeightCtrl,
    required TextEditingController buyingPriceCtrl,
    required TextEditingController buyingColorCtrl,
    required TextEditingController buyerContactCtrl,
    required TextEditingController finalColorCtrl,
    required TextEditingController finalWeightCtrl,
    required double currentBaselineWeight,
    required List<String> firstLookPhotos,
    required String? firstLookVideo,
    required bool isCertified,
    required List<CertificateModel> certificates,
  }) {
    switch (step) {
      case 0:
        if (varietyCtrl.text.isEmpty) {
          varietyCtrl.text = category == GemCategory.other
              ? customCategoryCtrl.text
              : category.displayName;
        }
        return const InventoryFormStepValidatorResult(isValid: true);

      case 1:
        if (varietyCtrl.text.isEmpty) {
          varietyCtrl.text = category == GemCategory.other
              ? customCategoryCtrl.text
              : category.displayName;
        }

        if (buyingWeightCtrl.text.trim().isEmpty ||
            double.tryParse(buyingWeightCtrl.text) == null) {
          return const InventoryFormStepValidatorResult(isValid: false);
        }

        if (buyingPriceCtrl.text.trim().isEmpty ||
            double.tryParse(buyingPriceCtrl.text) == null) {
          return const InventoryFormStepValidatorResult(isValid: false);
        }

        if (buyingColorCtrl.text.trim().isEmpty) {
          return const InventoryFormStepValidatorResult(isValid: false);
        }

        if (buyerContactCtrl.text.isNotEmpty) {
          buyerContactCtrl.text =
              buyerContactCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
        }

        return const InventoryFormStepValidatorResult(isValid: true);

      case 2:
        final imgCount = firstLookPhotos.length;
        final hasVid = firstLookVideo != null;

        if (imgCount < 2 && !hasVid) {
          return InventoryFormStepValidatorResult(
            isValid: false,
            errorMessage:
                'Please add ${2 - imgCount} more image(s) and 1 video.',
          );
        } else if (imgCount < 2) {
          return InventoryFormStepValidatorResult(
            isValid: false,
            errorMessage: 'Please add ${2 - imgCount} more image(s).',
          );
        } else if (!hasVid) {
          return const InventoryFormStepValidatorResult(
            isValid: false,
            errorMessage: 'Please add 1 video.',
          );
        }

        return const InventoryFormStepValidatorResult(isValid: true);

      case 3:
        return const InventoryFormStepValidatorResult(isValid: true);

      case 4:
        if (finalColorCtrl.text.trim().isEmpty) {
          finalColorCtrl.text = buyingColorCtrl.text;
        }

        if (finalWeightCtrl.text.trim().isEmpty) {
          finalWeightCtrl.text = currentBaselineWeight > 0
              ? currentBaselineWeight.toString()
              : buyingWeightCtrl.text;
        }

        if (finalWeightCtrl.text.trim().isEmpty) {
          return const InventoryFormStepValidatorResult(isValid: false);
        }

        return const InventoryFormStepValidatorResult(isValid: true);

      case 5:
        return const InventoryFormStepValidatorResult(isValid: true);

      case 6:
        if (isCertified && certificates.isEmpty) {
          return const InventoryFormStepValidatorResult(
            isValid: false,
            errorMessage:
                'Please add at least one certificate or disable certification.',
          );
        }
        return const InventoryFormStepValidatorResult(isValid: true);

      default:
        return const InventoryFormStepValidatorResult(isValid: true);
    }
  }

  /// Validates all form constraints prior to submission.
  static bool validateAllSteps({
    required GlobalKey<FormState> formKey,
    required TextEditingController buyingWeightCtrl,
    required TextEditingController buyingPriceCtrl,
    required TextEditingController finalWeightCtrl,
  }) {
    final isMainFormValid = formKey.currentState?.validate() ?? false;
    if (!isMainFormValid) return false;

    if (buyingWeightCtrl.text.isEmpty ||
        double.tryParse(buyingWeightCtrl.text) == null) {
      return false;
    }

    if (buyingPriceCtrl.text.isEmpty ||
        double.tryParse(buyingPriceCtrl.text) == null) {
      return false;
    }

    if (finalWeightCtrl.text.isEmpty ||
        double.tryParse(finalWeightCtrl.text) == null) {
      return false;
    }

    return true;
  }
}

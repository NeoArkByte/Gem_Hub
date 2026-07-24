import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date picker form tile component shared across Add and Update entry screens.
class InventoryDatePickerTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onSelect;

  const InventoryDatePickerTile({
    super.key,
    required this.label,
    required this.date,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
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
}

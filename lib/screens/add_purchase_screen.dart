import 'package:debtortrack/models/purchase_entry.dart';
import 'package:flutter/material.dart';
import 'package:debtortrack/core/theme/app_colors.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _AddPurchaseScreenState();
  }
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final TextEditingController _purchaseDescriptionController =
      TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  DateTime? _purchaseDate;
 
@override
void dispose() {
  _purchaseDescriptionController.dispose();
  _purchaseDateController.dispose();
  super.dispose();
}

  void _pickPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _purchaseDate = picked;
        _purchaseDateController.text = picked
            .toIso8601String()
            .split('T')
            .first;
      });
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  InputDecoration _fieldDecoration({
    required String label,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF716580)),
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE1DAEA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE1DAEA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentPurple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFF),
      appBar: AppBar(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Add Purchase',
          style: ThemeData.light().textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _purchaseDescriptionController,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration(label: 'What did they buy'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter what they bought';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _purchaseDateController,
                decoration: _fieldDecoration(
                  label: 'Purchase Date',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a purchase date';
                  }
                  return null;
                },
                onTap: () {
                  _pickPurchaseDate();
                },
                readOnly: true,
              ),

              const SizedBox(height: 32),

SizedBox(
  height: 56,
  child: FilledButton(
    onPressed: () {
      if (!_formKey.currentState!.validate()) return;

      final purchase = PurchaseEntry(
        description: _purchaseDescriptionController.text.trim(),
        purchaseDate: _purchaseDate!,
      );

      Navigator.pop(context, purchase);
    },
    style: FilledButton.styleFrom(
      backgroundColor: accentPurple,
      foregroundColor: Colors.white,
    ),
    child: const Text('Save purchase'),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}

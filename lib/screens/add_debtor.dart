import 'package:debtortrack/models/debtor_model.dart';
import 'package:flutter/material.dart';

class AddDebtorScreen extends StatefulWidget {
  final DebtorModel? existingDebtor;

  const AddDebtorScreen({super.key, this.existingDebtor});

  @override
  State<AddDebtorScreen> createState() => _AddDebtorScreenState();
}

class _AddDebtorScreenState extends State<AddDebtorScreen> {
  static const _brandPurple = Color(0xFF2B1950);
  static const _accentPurple = Color(0xFF4D2C8D);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  DateTime? _selectedDueDate;
  bool _isPaid = false;
  bool get _isEditing => widget.existingDebtor != null;

  @override
  void initState() {
    super.initState();
    final debtor = widget.existingDebtor;
    if (debtor != null) {
      _nameController.text = debtor.name;
      _amountController.text = debtor.amount.toString();
      _emailController.text = debtor.email;
      _selectedDueDate = debtor.dueDate;
      _dueDateController.text = debtor.dueDate
          .toLocal()
          .toIso8601String()
          .split('T')
          .first;
      _isPaid = debtor.isPaid;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _emailController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2026),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateController.text = picked.toIso8601String().split('T').first;
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
        borderSide: const BorderSide(color: _accentPurple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFF),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit debtor' : 'Add debtor'),
        backgroundColor: _brandPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration(label: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Shows amount textform
              TextFormField(
                controller: _amountController,
                decoration: _fieldDecoration(
                  label: 'Amount owed',
                  prefixText: r'$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // The Email textform
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDecoration(label: 'Email address'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !value.contains('@') ||
                      !value.contains('.com')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // The Date form
              TextFormField(
                controller: _dueDateController,
                decoration: _fieldDecoration(
                  label: 'Due date',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a due date';
                  }
                  return null;
                },
                onTap: () {
                  _pickDueDate();
                },
                readOnly: true,
              ),

              if (_isEditing)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Paid'),
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value;
                    });
                  },
                ),

              const SizedBox(height: 32),
              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final debtor = DebtorModel(
                        name: _nameController.text.trim(),
                        amount: double.parse(_amountController.text),
                        email: _emailController.text.trim(),
                        dueDate: _selectedDueDate!,
                        isPaid: _isPaid,
                      );
                      Navigator.pop(context, debtor);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _accentPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(_isEditing ? 'Save changes' : 'Save debtor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:debtortrack/core/utilities/saved_currency_code.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'add_debtor.dart';
import 'debtor_details_screen.dart';
import 'settings_screen.dart';

import 'package:debtortrack/models/debtor_model.dart';

import 'dart:convert';

import 'package:debtortrack/core/utilities/format_moni_currency.dart';
import 'package:debtortrack/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebtorListScreen extends StatefulWidget {
  const DebtorListScreen({super.key});

  @override
  State<DebtorListScreen> createState() => _DebtorListScreenState();
}

class _DebtorListScreenState extends State<DebtorListScreen> {
  final List<DebtorModel> debtors = [];

  double get _totalOutstanding => debtors
      .where((debtor) => !debtor.isPaid)
      .fold(0, (total, debtor) => total + debtor.amount);

  String _searchQuery = '';

 


  List<DebtorModel> get _filteredDebtors {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return debtors;
    }

    return debtors.where((debtor) {
      return debtor.name.toLowerCase().contains(query);
    }).toList();
  }

  String get _formattedTotalOutstanding =>
      formatMoniCurrency(_totalOutstanding, currencyCode: selectedCode);

  double _rawAmount(DebtorModel debtor) => debtor.amount;

  String _formattedDebtorAmount(DebtorModel debtor) =>
      formatMoniCurrency(_rawAmount(debtor), currencyCode: selectedCode);

  String selectedCode = 'USD'; // Default currency code

  @override
  void initState() {
    super.initState();
    _loadDebtors();
    _loadTargetCurrency();
  }

  Future<void> _loadTargetCurrency() async {
    final code = await getEffectiveCurrencyCode();

    if (!mounted) return;
    setState(() => selectedCode = code);
  }

  // Convert every debtor to debtors using toMap()
  Future<void> _loadDebtors() async {
    final prefs = await SharedPreferences.getInstance();
    final String? debtorsJson = prefs.getString('debtors');
    if (debtorsJson != null) {
      final List<dynamic> debtorList = jsonDecode(debtorsJson);
      setState(() {
        debtors.clear();
        debtors.addAll(
          debtorList
              .map((debtorMap) => DebtorModel.fromMap(debtorMap))
              .toList(),
        );
      });
    }
  }

  // Saves the debtor to Shared Pref
  Future<void> _saveDebtors() async {
    final prefs = await SharedPreferences.getInstance();
    final String debtorsJson = jsonEncode(
      debtors.map((debtor) => debtor.toMap()).toList(),
    );
    await prefs.setString('debtors', debtorsJson);
  }

  // Adds a method to display the list of debtors or a message if the list is empty
  Widget debtorList() {
    if (debtors.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: mutedTextColor),
            SizedBox(height: 16),
            Text('No debtors added yet.'),
            Text('Tap the + button to add a new debtor.'),
          ],
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        itemCount: _filteredDebtors.length,
        itemBuilder: (context, index) {
          final debtor = _filteredDebtors[index];
          final status = debtor.getStatus();
          final statusColors = switch (status) {
            'Overdue' => (
              background: const Color(0xFFFDE8E7),
              text: const Color(0xFFC62828),
            ),
            'Due Today' => (
              background: const Color(0xFFFFF1E0),
              text: const Color(0xFFEF6C00),
            ),
            'Paid' => (
              background: const Color(0xFFE7F6EC),
              text: const Color(0xFF2E7D32),
            ),
            _ => (
              background: const Color(0xFFEDE7F6),
              text: const Color(0xFF4D2C8D),
            ),
          };
          final dueDate = debtor.dueDate
              .toLocal()
              .toIso8601String()
              .split('T')
              .first;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFEAE4F0)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                // The details screen returns either an edit or delete action.
                final result = await Navigator.push<DebtorDetailsResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DebtorDetailsScreen(
                      debtor: debtor,
                      currencyCode: selectedCode,
                    ),
                  ),
                );

                if (result == null) {
                  return;
                }

                if (result.action == DebtorDetailsAction.deleted) {
                  // `index` belongs to the filtered list. Find the debtor's
                  // actual position in the full list before removing it.
                  final originalIndex = debtors.indexOf(debtor);
                  setState(() => debtors.removeAt(originalIndex));
                  await _saveDebtors();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Debtor deleted'),
                      backgroundColor: Color(0xFF4D2C8D),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (result.debtor != null) {
                  // `index` belongs to the filtered list, so use the original
                  // list position when replacing an edited debtor.
                  final originalIndex = debtors.indexOf(debtor);
                  setState(() => debtors[originalIndex] = result.debtor!);
                  await _saveDebtors();
                }
              },

              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: accentPurple,
                      child: Text(
                        debtor.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debtor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Due: $dueDate',
                            style: const TextStyle(color: Color(0xFF716580)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formattedDebtorAmount(debtor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF24202A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColors.background,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColors.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandPurple,
      appBar: AppBar(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'DebtorTrack',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: const Color(0xFFFCFAFF),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              await _loadTargetCurrency(); // Reload the target currency after returning from settings
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total outstanding',
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: mutedTextColor, fontSize: 16),
                ),
                const SizedBox(height: 6),

                // Converts the outstanding amount to String
                Text(
                  _formattedTotalOutstanding,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    shape: BoxShape.rectangle,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (_) {
                       FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search debtors',
                      prefixIcon: Image.asset(
                        'assets/icons/icons8-search-user-100.png',
                        height: 30,
                      ),

                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFCFAFF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: debtorList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the Add Debtor screen
          final debtor = await Navigator.push<DebtorModel>(
            context,
            MaterialPageRoute(builder: (context) => AddDebtorScreen()),
          );
          if (debtor != null) {
            setState(() => debtors.add(debtor));
            // Save the updated list of debtors to shared preferences
            await _saveDebtors();
          }
        },
        backgroundColor: accentPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

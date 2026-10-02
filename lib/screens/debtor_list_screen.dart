import 'package:flutter/material.dart';

import 'add_debtor.dart';
import 'debtor_details_screen.dart';
import 'settings_screen.dart';

import 'package:debtortrack/models/debtor_model.dart';

import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadDebtors();
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
        itemCount: debtors.length,
        itemBuilder: (context, index) {
          final debtor = debtors[index];
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
                    builder: (context) => DebtorDetailsScreen(debtor: debtor),
                  ),
                );

                if (result == null) {
                  return;
                }

                if (result.action == DebtorDetailsAction.deleted) {
                  setState(() => debtors.removeAt(index));
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
                  // Editing replaces the old item at the same list position.
                  setState(() => debtors[index] = result.debtor!);
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
                          '\$${debtor.amount.toStringAsFixed(2)}',
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
        title:  Text(
          'DebtorTrack',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: const Color(0xFFFCFAFF),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
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
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: mutedTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),

                // Converts the outstanding amount to String
                Text(
                  '₦${_totalOutstanding.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
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

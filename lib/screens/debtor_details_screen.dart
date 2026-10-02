import 'package:debtortrack/models/debtor_model.dart';
import 'package:debtortrack/screens/add_debtor.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';

// This tells the list screen what happened when the details screen closed.
enum DebtorDetailsAction { updated, deleted }

class DebtorDetailsResult {
  final DebtorDetailsAction action;
  final DebtorModel? debtor;

  const DebtorDetailsResult.updated(this.debtor)
    : action = DebtorDetailsAction.updated;

  const DebtorDetailsResult.deleted(this.debtor)
    : action = DebtorDetailsAction.deleted;
}

class DebtorDetailsScreen extends StatelessWidget {
  final DebtorModel debtor;

  const DebtorDetailsScreen({super.key, required this.debtor});

  Future<void> _sendReminder(BuildContext context) async {
    final subject = 'Payment Reminder';
    final body =
        'Hello ${debtor.name},\n\n'
        'This is a gentle reminder that your outstanding balance of '
        '₦${debtor.amount.toStringAsFixed(2)} is due on '
        '${debtor.dueDate.toLocal().toIso8601String().split('T').first}.\n\n'
        'Thank you.';

    final emailUri = Uri(
      scheme: 'mailto',
      path: debtor.email,
      query:
          'subject=${Uri.encodeComponent(subject)}&'
          'body=${Uri.encodeComponent(body)}',
    );

    final launched = await launchUrl(emailUri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email app is available on this device.'),
        ),
      );
    }
  }

  Future<void> _editDebtor(BuildContext context) async {
    final updatedDebtor = await Navigator.push<DebtorModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddDebtorScreen(existingDebtor: debtor),
      ),
    );

    if (updatedDebtor != null && context.mounted) {
      // Return the edited debtor to the existing list screen.
      Navigator.pop(context, DebtorDetailsResult.updated(updatedDebtor));
    }
  }

  Future<void> _deleteDebtor(BuildContext context) async {
    // Ask for confirmation before performing a destructive action.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete debtor?',
            style: ThemeData.light().textTheme.titleLarge?.copyWith(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Delete ${debtor.name}. \nThis cannot be undone.',
            style: ThemeData.light().textTheme.labelMedium?.copyWith(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: ThemeData.light().textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: accentPurple,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Delete',
                style: ThemeData.light().textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      // The list screen owns the collection, so it will remove and save it.
      Navigator.pop(context, DebtorDetailsResult.deleted(debtor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = debtor.name.isEmpty ? '?' : debtor.name[0].toUpperCase();
    final dueDate = debtor.dueDate.toLocal().toIso8601String().split('T').first;
    final status = debtor.getStatus();
    final statusColor = switch (status) {
      'Overdue' => const Color(0xFFC62828),
      'Due Today' => const Color(0xFFEF6C00),
      'Paid' => const Color(0xFF2E7D32),
      _ => accentPurple,
    };
    final statusBackground = switch (status) {
      'Overdue' => const Color(0xFFFDE8E7),
      'Due Today' => const Color(0xFFFFF1E0),
      'Paid' => const Color(0xFFE7F6EC),
      _ => const Color(0xFFEDE7F6),
    };

    return Scaffold(
      backgroundColor: brandPurple,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                          tooltip: 'Back',
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _editDebtor(context),
                          icon: const Icon(Icons.edit_outlined),
                          color: Colors.white,
                          tooltip: 'Edit debtor',
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => _deleteDebtor(context),
                          icon: Icon(Icons.delete_outline),
                          color: Colors.white,
                          tooltip: 'Delete debtor',
                        ),
                      ],
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFF594575),
                      child: Text(
                        initial,
                        style: ThemeData.light().textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      debtor.name,
                      style: ThemeData.light().textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      debtor.email,
                      style: ThemeData.light().textTheme.labelMedium?.copyWith(
                        color: mutedTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCFAFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: statusBackground,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount owed',
                              style: ThemeData.light().textTheme.labelLarge
                                  ?.copyWith(
                                    color: statusColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            SizedBox(height: 12),

                            Text(
                              '\$${debtor.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF24202A),
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: debtor.isPaid
                                  ? null
                                  : () {
                                      debtor.isPaid = true;
                                      Navigator.pop(
                                        context,
                                        DebtorDetailsResult.updated(debtor),
                                      );
                                    },
                              icon: const Icon(Icons.check),
                              label: Text(
                                debtor.isPaid ? 'Paid' : 'Mark as paid',
                                style: ThemeData.light().textTheme.labelLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF20A66D),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: debtor.isPaid
                                  ? null
                                  : () => _sendReminder(context),
                              icon: const Icon(Icons.email_outlined),
                              label: Text(
                                'Send reminder',
                                style: ThemeData.light().textTheme.labelLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color:accentPurple,
                                    ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accentPurple,
                                side: const BorderSide(
                                  color: accentPurple,
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 17,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                       Text(
                        'DETAILS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: mutedTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                          color: accentPurple,
                        ),
                        title: const Text('Due date'),
                        trailing: Text(
                          dueDate,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w100,
                            color: mutedTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

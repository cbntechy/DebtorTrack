import 'package:debtortrack/core/utilities/format_moni_currency.dart';
import 'package:debtortrack/models/debtor_model.dart';
import 'package:debtortrack/screens/add_debtor.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:debtortrack/models/purchase_entry.dart';
import 'package:debtortrack/screens/add_purchase_screen.dart';
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

class DebtorDetailsScreen extends StatefulWidget {
  final DebtorModel debtor;
  final String currencyCode;

  const DebtorDetailsScreen({
    super.key,
    required this.debtor,
    required this.currencyCode,
  });

  @override
  State<DebtorDetailsScreen> createState() => _DebtorDetailsScreenState();
}

class _DebtorDetailsScreenState extends State<DebtorDetailsScreen> {
  Future<void> _addPurchase() async {
  final purchase = await Navigator.push<PurchaseEntry>(
    context,
    MaterialPageRoute(
      builder: (context) => const AddPurchaseScreen(),
    ),
  );

  if (purchase == null || !mounted) return;

  setState(() {
    widget.debtor.purchaseHistory.add(purchase);
  });
}
  String _reminderBody() {
    final formattedAmount = formatMoniCurrency(
      widget.debtor.amount,
      currencyCode: widget.currencyCode,
    );

    return
        'Hello ${widget.debtor.name},\n\n'
        'This is a gentle reminder that your outstanding balance of '
        '$formattedAmount is due on '
        '${widget.debtor.dueDate.toLocal().toIso8601String().split('T').first}.\n\n'
        'Thank you.';
  }

  Future<void> _sendReminder(BuildContext context) async {
    if (widget.debtor.preferredChannel == ReminderChannel.email) {
      await _sendEmailReminder(context);
    } else {
      await _sendWhatsAppReminder(context);
    }
  }

  Future<void> _sendEmailReminder(BuildContext context) async {
    if (widget.debtor.email.isEmpty) {
      _showMessage(context, 'This debtor has no email address.');
      return;
    }

    final subject = 'Payment Reminder';
    final body = _reminderBody();

    final emailUri = Uri(
      scheme: 'mailto',
      path: widget.debtor.email,
      query:
          'subject=${Uri.encodeComponent(subject)}&'
          'body=${Uri.encodeComponent(body)}',
    );

    final launched = await launchUrl(emailUri);
    if (!launched && context.mounted) {
      _showMessage(context, 'No email app is available on this device.');
    }
  }

  Future<void> _sendWhatsAppReminder(BuildContext context) async {
    final phoneNumber = widget.debtor.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (phoneNumber.isEmpty) {
      _showMessage(context, 'This debtor has no WhatsApp number.');
      return;
    }

    final whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(_reminderBody())}',
    );

    final launched = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      _showMessage(context, 'WhatsApp could not be opened on this device.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _editDebtor(BuildContext context) async {
    final updatedDebtor = await Navigator.push<DebtorModel>(
      context,
      MaterialPageRoute(
        builder: (context) => AddDebtorScreen(existingDebtor: widget.debtor),
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
            'Delete ${widget.debtor.name}. \nThis cannot be undone.',
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
      Navigator.pop(context, DebtorDetailsResult.deleted(widget.debtor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.debtor.name.isEmpty ? '?' : widget.debtor.name[0].toUpperCase();
    final preferredContact =
        widget.debtor.preferredChannel == ReminderChannel.email
        ? widget.debtor.email
        : widget.debtor.phoneNumber;
   // final dueDate = widget.debtor.dueDate.toLocal().toIso8601String().split('T').first;
    final status = widget.debtor.getStatus();
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
                      widget.debtor.name,
                      style: ThemeData.light().textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preferredContact.isEmpty
                          ? 'No ${widget.debtor.preferredChannel == ReminderChannel.email ? 'email address' : 'WhatsApp number'}'
                          : preferredContact,
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
              flex: 8,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCFAFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
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
                              formatMoniCurrency(
                                widget.debtor.amount,
                                currencyCode: widget.currencyCode,
                              ),
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: widget.debtor.isPaid
                                  ? null
                                  : () {
                                      widget.debtor.isPaid = true;
                                      Navigator.pop(
                                        context,
                                        DebtorDetailsResult.updated(widget.debtor),
                                      );
                                    },
                              icon: const Icon(Icons.check),
                              label: Text(
                                widget.debtor.isPaid ? 'Paid' : 'Mark as paid',
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
                              onPressed: widget.debtor.isPaid
                                  ? null
                                  : () => _sendReminder(context),
                              icon: Icon(
                                widget.debtor.preferredChannel ==
                                        ReminderChannel.email
                                    ? Icons.email_outlined
                                    : Icons.chat_outlined,
                              ),
                              label: Text(
                                widget.debtor.preferredChannel ==
                                        ReminderChannel.email
                                    ? 'Email'
                                    : 'WhatsApp',
                                style: ThemeData.light().textTheme.labelLarge
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: accentPurple,
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
                        'Notes',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: accentPurple,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    
                     




const SizedBox(height: 8),

Text(
  widget.debtor.note.isEmpty
      ? 'No notes added.'
      : widget.debtor.note,
  style: const TextStyle(
    color: Color(0xFF24202A),
    height: 1.5,
  ),
),

const SizedBox(height: 8),
Row(
  children: [
    Text(
      'PURCHASE HISTORY',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: accentPurple,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    const Spacer(),
    TextButton.icon(
      onPressed: _addPurchase,
      icon: const Icon(Icons.add),
      label: const Text('Add purchase'),
    ),
  ],
),

if (widget.debtor.purchaseHistory.isEmpty)
  const Text(
    'No purchases recorded yet.',
    style: TextStyle(color: Color(0xFF716580)),
  )
else
  ...widget.debtor.purchaseHistory.map((entry) {
    final purchaseDate = entry.purchaseDate
        .toLocal()
        .toIso8601String()
        .split('T')
        .first;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(
        Icons.receipt_long_outlined,
        color: accentPurple,
      ),
      title: Text(entry.description),
      trailing: Text(
        purchaseDate,
        style:  Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w100,
                                color: Colors.black,
                              ),
      ),
    );
  }),

 
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

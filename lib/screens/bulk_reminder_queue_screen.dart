import 'package:debtortrack/core/utilities/format_moni_currency.dart';
import 'package:debtortrack/models/debtor_model.dart';
import 'package:debtortrack/models/message_template.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BulkReminderQueueScreen extends StatefulWidget {
  final List<DebtorModel> debtors;
  final MessageTemplate template;
  final String currencyCode;

  const BulkReminderQueueScreen({
    super.key,
    required this.debtors,
    required this.template,
    required this.currencyCode,
  });

  @override
  State<BulkReminderQueueScreen> createState() =>
      _BulkReminderQueueScreenState();
}

class _BulkReminderQueueScreenState extends State<BulkReminderQueueScreen> {
  int _currentIndex = 0;
  bool _openedCurrentReminder = false;

  DebtorModel get _currentDebtor => widget.debtors[_currentIndex];

  String _reminderBody(DebtorModel debtor) {
    final amount = formatMoniCurrency(
      debtor.amount,
      currencyCode: widget.currencyCode,
    );

    final dueDate = debtor.dueDate
        .toLocal()
        .toIso8601String()
        .split('T')
        .first;

    return widget.template.body
        .replaceAll('{name}', debtor.name)
        .replaceAll('{amount}', amount)
        .replaceAll('{dueDate}', dueDate);
  }

  Future<void> _openReminder() async {
    final debtor = _currentDebtor;
    final body = _reminderBody(debtor);

    final Uri uri;

    if (debtor.preferredChannel == ReminderChannel.email) {
      uri = Uri(
        scheme: 'mailto',
        path: debtor.email,
        query:
            'subject=${Uri.encodeComponent('Payment Reminder')}&'
            'body=${Uri.encodeComponent(body)}',
      );
    } else {
      final number = debtor.phoneNumber.replaceAll(RegExp(r'\D'), '');

      uri = Uri.parse(
        'https://wa.me/$number?text=${Uri.encodeComponent(body)}',
      );
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;

    if (launched) {
      setState(() {
        _openedCurrentReminder = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the selected reminder channel.'),
        ),
      );
    }
  }

  void _nextDebtor() {
    final isLastDebtor = _currentIndex == widget.debtors.length - 1;

    if (isLastDebtor) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _currentIndex++;
      _openedCurrentReminder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final debtor = _currentDebtor;
    final isLastDebtor = _currentIndex == widget.debtors.length - 1;

    final channelName = debtor.preferredChannel == ReminderChannel.email
        ? 'Email'
        : 'WhatsApp';

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder ${_currentIndex + 1} of ${widget.debtors.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              debtor.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Send through $channelName'),
            const SizedBox(height: 24),

            Text(
              'Message preview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(_reminderBody(debtor)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _openReminder,
              icon: Icon(
                debtor.preferredChannel == ReminderChannel.email
                    ? Icons.email_outlined
                    : Icons.chat_outlined,
              ),
              label: Text('Open $channelName'),
            ),

            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: _openedCurrentReminder ? _nextDebtor : null,
              child: Text(
                isLastDebtor ? 'I sent it — finish' : 'I sent it — next',
              ),
            ),

            TextButton(
              onPressed: _nextDebtor,
              child: const Text('Skip this debtor'),
            ),
          ],
        ),
      ),
    );
  }
}
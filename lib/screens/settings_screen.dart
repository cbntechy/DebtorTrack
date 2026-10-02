import 'package:flutter/material.dart';
import 'package:debtortrack/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _privacyPolicy(BuildContext context) async {
    final httpUri = Uri.parse('https://cbntechy.github.io/DebtorTrack_privacy');

    final launched = await launchUrl(httpUri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your browser could not open the link.')),
      );
    }
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final subject = 'DebtorTrack User Feedback';
    final body =
        'Hello \n\n'
        'I would like to share some feedback about my experience using DebtorTrack.'
        '[User\'s message].\n\n'
        'Thank you.';

    final emailUri = Uri(
      scheme: 'mailto',
      path: 'supportdebtortrack@gmail.com',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAFF),
      appBar: AppBar(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title:  Text(
          'Settings',
          style: ThemeData.light().textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        children: [
          ListTile(
            title: Text("Privacy Policy", style: ThemeData.light().textTheme.titleMedium?.copyWith(
              color: accentPurple,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),),
            minVerticalPadding: 18,
            onTap: () => _privacyPolicy(context),
          ),

          Divider(thickness: 1, color: Color(0xFF4D2C8D),),

          ListTile(
            title: Text("Send Feedback", style: ThemeData.light().textTheme.titleMedium?.copyWith(
              color: accentPurple,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),),
            subtitle: Text('Tell us what you think should be improved', style: ThemeData.light().textTheme.labelMedium?.copyWith(
              color: Color(0xFF827292),
              fontSize: 14,
            ),),
            minVerticalPadding: 18,
            onTap: () {
              _sendFeedback(context);
            },
          ),

          Divider(thickness: 1, color: Color(0xFF4D2C8D),),
        ],
      ),
    );
  }
}

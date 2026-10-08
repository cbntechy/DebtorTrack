
import 'package:flutter/material.dart';
import 'package:debtortrack/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_picker/currency_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Function to open the privacy policy link in the browser
  Future<void> _privacyPolicy(BuildContext context) async {
    final httpUri = Uri.parse('https://cbntechy.github.io/DebtorTrack_privacy');
    final launched = await launchUrl(httpUri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your browser could not open the link.')),
      );
    }
  }

  // Function to send feedback via email
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

  // Function to display currency picker for currency selection
  void _showCurrencyPicker(BuildContext context) {
    showCurrencyPicker(
      context: context,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      theme: CurrencyPickerThemeData(
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Search by currency name or code',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      onSelect: (currency) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('targetCurrency', currency.code);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Currency set to ${currency.name}'),
            ),
          );
        }
      },
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
         
            
              Text(
                'ACCOUNT',
                style: ThemeData.light().textTheme.titleLarge?.copyWith(
                  color: accentPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              ListTile(
                title: Text(
                  'Currency',
                  style: ThemeData.light().textTheme.titleMedium?.copyWith(
                    color: accentPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  'Set your preferred display currency for transactions',
                  style: ThemeData.light().textTheme.labelMedium?.copyWith(
                    color: mutedTextColor,
                    fontSize: 14,
                  ),
                ),
                minVerticalPadding: 18,
                onTap: () => _showCurrencyPicker(context),
              ),

              Divider(thickness: 1, color: Color.fromARGB(255, 95, 67, 153)),
              
              Text(
                'SUPPORT',
                style: ThemeData.light().textTheme.titleLarge?.copyWith(
                  color: accentPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              ListTile(
                title: Text(
                  "Privacy Policy",
                  style: ThemeData.light().textTheme.titleMedium?.copyWith(
                    color: accentPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                minVerticalPadding: 18,
                onTap: () => _privacyPolicy(context),
              ),

              ListTile(
                title: Text(
                  "Send Feedback",
                  style: ThemeData.light().textTheme.titleMedium?.copyWith(
                    color: accentPurple,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  'Tell us what you think should be improved',
                  style: ThemeData.light().textTheme.labelMedium?.copyWith(
                    color: mutedTextColor,
                    fontSize: 14,
                  ),
                ),
                minVerticalPadding: 18,
                onTap: () {
                  _sendFeedback(context);
                },

              ),
                Divider(thickness: 1, color: Color.fromARGB(255, 95, 67, 153)),
            ],
          ),

        
      
    );
  }
}

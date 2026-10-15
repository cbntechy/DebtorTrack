
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> rateApp(BuildContext context) async {
  final String appStoreUrl =
      'https://play.google.com/store/apps/details?id=com.learntobuild.debtortrack';

  final Uri url = Uri.parse(appStoreUrl);

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the app store.',style: TextStyle(color: Colors.white),),
         backgroundColor: Color(0xFF4D2C8D),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 16,
                      ),
                      behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
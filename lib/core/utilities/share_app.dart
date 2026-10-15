import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

Future<void> shareApp(BuildContext context) async {
  final String appUrl =
      'https://play.google.com/store/apps/details?id=com.learntobuild.debtortrack';
  final ShareParams message = ShareParams(
    text: 'Check out this amazing app: DebtorTrack! $appUrl',
  );

  final messenger = ScaffoldMessenger.maybeOf(context);

  try {
    final result = await SharePlus.instance.share(message);

    if (result.status == ShareResultStatus.success) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Thank you for sharing my app!')),
      );
    }
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(content: Text('Error sharing app: $e')),
    );
  }
}

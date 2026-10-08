import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatMoniCurrency(double amount, {String? currencyCode, }) {
  final locale = PlatformDispatcher.instance.locale.toString();
  final formatter = NumberFormat.simpleCurrency(
    locale: locale,
    name: currencyCode,
    
  );
  return formatter.format(amount);
}

Future<void> saveBaseCurrency() async {
  final prefs = await SharedPreferences.getInstance();

  final existing = prefs.getString('baseCurrency');
  if (existing != null && existing.isNotEmpty) {
    return;
  }

  final locale = PlatformDispatcher.instance.locale.toString();
  final formatter = NumberFormat.simpleCurrency(locale: locale);

  final currencyCode = formatter.currencyName;

  if (currencyCode == null || currencyCode.isEmpty) {
    return;
  }

  await prefs.setString('baseCurrency', currencyCode);
}
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:ui';


Future<String> getSavedCurrencyCode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('baseCurrency') ?? 'USD';
}

// Function that initializes the base and target currency preferences if they are not already set
Future<void> initializeCurrencyPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  final locale = PlatformDispatcher.instance.locale.toString();
  final detectedCode =
      NumberFormat.simpleCurrency(locale: locale).currencyName;

  final savedBase = prefs.getString('baseCurrency');
  final baseCode = savedBase != null && savedBase.isNotEmpty
      ? savedBase
      : (detectedCode ?? 'USD');

  if (savedBase == null || savedBase.isEmpty) {
    await prefs.setString('baseCurrency', baseCode);
  }

  final savedTarget = prefs.getString('targetCurrency');
  if (savedTarget == null || savedTarget.isEmpty) {
    await prefs.setString('targetCurrency', baseCode);
  }
}

Future<String> getEffectiveCurrencyCode() async {
  final prefs = await SharedPreferences.getInstance();

  // 1) Read both saved values
  final baseCurrency = prefs.getString('baseCurrency') ?? 'USD';
  final targetCurrency = prefs.getString('targetCurrency');

  // 2) Use the target if the user selected one
  // 3) Otherwise fall back to base currency
  if (targetCurrency != null && targetCurrency.isNotEmpty) {
    return targetCurrency;
  }

  return baseCurrency;
}
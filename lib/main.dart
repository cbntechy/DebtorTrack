import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:debtortrack/core/utilities/saved_currency_code.dart';
import 'package:debtortrack/core/services/notification_service.dart';

import 'onboardings/onboarding1_screen.dart';
import 'screens/debtor_list_screen.dart';
import 'core/theme/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'core/services/entitlement_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  const revenueCatAndroidApiKey =
    String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty || revenueCatAndroidApiKey.isEmpty) {
    throw StateError('Supabase configuration is missing.');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  final revenueCatConfiguration =
    PurchasesConfiguration(revenueCatAndroidApiKey)
      ..appUserID = Supabase.instance.client.auth.currentUser?.id;

await Purchases.configure(revenueCatConfiguration);

await EntitlementService.instance.refreshProStatus();

  await initializeCurrencyPreferences();
  await NotificationService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _onboardingComplete;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingComplete = prefs.getBool('onboardingComplete') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _onboardingComplete == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _onboardingComplete!
          ? const DebtorListScreen()
          : const Onboarding1Screen(),
    );
  }
}

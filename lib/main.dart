import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboardings/onboarding1_screen.dart';
import 'screens/debtor_list_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
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

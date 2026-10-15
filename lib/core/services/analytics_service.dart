import 'package:posthog_flutter/posthog_flutter.dart';

class AnalyticsService {
  AnalyticsService._();

  static Future<void> onboardingCompleted() async {
    await Posthog().capture(
      eventName: 'onboarding completed',
    );
  }
}
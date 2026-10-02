import 'package:debtortrack/screens/debtor_list_screen.dart';
import 'package:flutter/material.dart';
import 'onboarding3_screen.dart';
import 'onboarding_illustration.dart';
import '../core/theme/app_colors.dart';

class Onboarding2Screen extends StatelessWidget {
  const Onboarding2Screen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // The Align Widget was used to fit in the SKIP Button in its state.
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // Later: go straight to the debtor list screen.
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return DebtorListScreen();
                        },
                      ),
                      (route) => false,
                    );
                  },
                  child:  Text(
                    'Skip',
                    style: ThemeData.light().textTheme.labelLarge?.copyWith(
                      color: titleLargeText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const Center(
                child: OnboardingIllustration(
                  type: OnboardingIllustrationType.reminder,
                ),
              ),

              const Spacer(),

               Text(
                'Reminders go out automatically',
                style: ThemeData.light().textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                ),
              ),

              const SizedBox(height: 18),

               Text(
                'Set it once - DebtorTrack sends a gentle nudge before the due date and follows up if it\'s missed.',
                style: ThemeData.light().textTheme.labelLarge?.copyWith(
                  color: mutedTextColor,
                  fontSize: 18,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              const Row(
                children: [
                  _PageIndicator(),
                  SizedBox(width: 10),
                  _PageIndicator(isActive: true),
                  SizedBox(width: 10),
                  _PageIndicator(),
                  SizedBox(width: 10),
                  _PageIndicator(),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: () {
                    // Later: open onboarding page 2.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onboarding3Screen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: backgroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:  Text(
                    'Next',
                    style: ThemeData.light().textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: backgroundColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;

  const _PageIndicator({this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 40 : 14,
      height: 14,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFF827292),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

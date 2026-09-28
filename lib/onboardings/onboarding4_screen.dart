import 'package:debtortrack/screens/debtor_list_screen.dart';
import 'package:flutter/material.dart';
import 'onboarding_illustration.dart';

class Onboarding4Screen extends StatelessWidget {
  const Onboarding4Screen({super.key});

  static const Color backgroundColor = Color(0xFF2C1950);
  static const Color cardColor = Color(0xFF463563);
  static const Color mutedTextColor = Color(0xFFC9C0D8);

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

              const Spacer(),

              const Center(
                child: OnboardingIllustration(
                  type: OnboardingIllustrationType.complete,
                ),
              ),

              const Spacer(),

              const Text(
                'Keep every debt\nin one place',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Add debtors, amounts, and due dates without relying on memory.',
                style: TextStyle(
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
                  _PageIndicator(),
                  SizedBox(width: 10),
                  _PageIndicator(),
                  SizedBox(width: 10),
                  _PageIndicator(isActive: true),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: () {
                    // Later: open DebtorListScreen.
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: backgroundColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

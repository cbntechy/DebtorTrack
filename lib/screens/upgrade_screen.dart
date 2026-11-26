import 'package:flutter/material.dart';
import 'package:debtortrack/core/theme/app_colors.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brandPurple,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(10.0),
                  shape: BoxShape.rectangle,
                ),
                child: Text(
                  'EARLY-SUPPORTER PRICE',
                  style: ThemeData.light().textTheme.labelMedium?.copyWith(
                    color: mutedTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Unlock DebtorTrack Pro',
                style: ThemeData.light().textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pay once. Keep it forver.',
                style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                  color: cardColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
          
              const SizedBox(height: 20),
          
              ListTile(
                leading: const Icon(Icons.check, color: Colors.white),
                title: Text(
                  'Unlimited Debtors',
                  style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
          
              const SizedBox(height: 20),
          
              ListTile(
                leading: const Icon(Icons.check, color: Colors.white),
                title: Text(
                  'Message templates',
                  style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
          
              const SizedBox(height: 20),
          
              ListTile(
                leading: const Icon(Icons.check, color: Colors.white),
                title: Text(
                  'Send reminders to selected debtors',
                  style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
          
              const SizedBox(height: 20),
          
              ListTile(
                leading: const Icon(Icons.check, color: Colors.white),
                title: Text(
                  'Cloud backup of your debtor list',
                  style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
          
              const SizedBox(height: 20),
          
              ListTile(
                leading: const Icon(Icons.check, color: Colors.white),
                title: Text(
                  'Lifetime access to pro',
                  style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
          
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '\$2.99',
                    style: ThemeData.light().textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'One-time payment shown in your local currency',
                    style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                      color: cardColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Handle upgrade action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: brandPurple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Unlock Pro',
                      style: ThemeData.light().textTheme.bodyMedium?.copyWith(
                        color: brandPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No subscription. The price rises with each major update, but if you buy now you never pay again for Pro.',
                    style: ThemeData.light().textTheme.bodySmall?.copyWith(
                      color: cardColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Restore purchase',
                      style: ThemeData.light().textTheme.bodySmall?.copyWith(
                        color: cardColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

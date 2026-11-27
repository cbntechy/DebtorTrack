import 'package:flutter/material.dart';
import 'package:debtortrack/core/theme/app_colors.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:debtortrack/core/services/entitlement_service.dart';
import 'package:flutter/services.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  Package? _lifetimePackage;
  bool _isLoadingOffer = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    try {
      final offerings = await Purchases.getOfferings();

      if (!mounted) return;

      setState(() {
        _lifetimePackage = offerings.current?.lifetime;
        _isLoadingOffer = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingOffer = false;
      });
    }
  }

  Future<void> _purchasePro() async {
    final lifetimePackage = _lifetimePackage;

    if (lifetimePackage == null) {
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(lifetimePackage),
      );

      final hasPro = result.customerInfo.entitlements.active.containsKey(
        'debtortrack_pro',
      );

      EntitlementService.instance.updateProStatus(hasPro);

      if (!mounted) return;

      if (hasPro) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DebtorTrack Pro unlocked!')),
        );
        Navigator.pop(context, true);
      }
    } on PlatformException catch (error) {
      final errorCode = PurchasesErrorHelper.getErrorCode(error);

      if (errorCode != PurchasesErrorCode.purchaseCancelledError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase could not be completed. Please try again.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  //
  Future<void> _restorePurchase() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final customerInfo = await Purchases.restorePurchases();

      final hasPro = customerInfo.entitlements.active.containsKey(
        'debtortrack_pro',
      );

      EntitlementService.instance.updateProStatus(hasPro);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasPro
                ? 'DebtorTrack Pro restored!'
                : 'No previous Pro purchase was found.',
          ),
        ),
      );

      if (hasPro) {
        Navigator.pop(context, true);
      }
    } on PlatformException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not restore purchases.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

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
                'Pay once. Keep it forever.',
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
                    _isLoadingOffer
                        ? 'Loading price...'
                        : _lifetimePackage?.storeProduct.priceString ??
                              'Price unavailable',
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
                      _isLoadingOffer ||
                              _lifetimePackage == null ||
                              _isPurchasing
                          ? null
                          : _purchasePro;
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
                    child: _isPurchasing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Unlock Pro',
                            style: ThemeData.light().textTheme.bodyMedium
                                ?.copyWith(
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
                    child: TextButton(
                      onPressed: _isPurchasing ? null : _restorePurchase,
                      child: Text(
                        'Restore purchase',
                        style: ThemeData.light().textTheme.bodySmall?.copyWith(
                          color: cardColor,
                          fontSize: 12,
                        ),
                      ),
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

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class EntitlementService extends ChangeNotifier {
  EntitlementService._();

  static final EntitlementService instance = EntitlementService._();

  bool _isPro = false;

  bool get isPro => _isPro;

  Future<void> refreshProStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      updateProStatus(
        customerInfo.entitlements.active.containsKey('debtortrack_pro'),
      );
    } catch (_) {
      updateProStatus(false);
    }
  }

  void updateProStatus(bool value) {
    if (_isPro == value) return;

    _isPro = value;
    notifyListeners();
  }
}
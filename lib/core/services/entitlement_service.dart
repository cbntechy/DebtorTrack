class EntitlementService {
  EntitlementService._();

  static final EntitlementService instance = EntitlementService._();

  bool _isPro = true;

  bool get isPro => _isPro;

  void updateProStatus(bool value) {
    _isPro = value;
  }
}

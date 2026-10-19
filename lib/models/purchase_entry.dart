class PurchaseEntry {
  final String description;
  final DateTime purchaseDate;

  PurchaseEntry({required this.description, required this.purchaseDate});

  Map<String, dynamic> toMap() {
    return {'description': description, 'purchaseDate': purchaseDate.toIso8601String()};
  }

  factory PurchaseEntry.fromMap(Map<String, dynamic> map) {
    return PurchaseEntry(description: map['description'], purchaseDate: DateTime.parse( map['purchaseDate']));
  }
}

import 'package:debtortrack/models/purchase_entry.dart';
class DebtorModel {
  final String name;
  final double amount;
  final String email;
  final DateTime dueDate;
 bool isPaid;
 final List<PurchaseEntry> purchaseHistory;

DebtorModel({
  required this.name,
  required this.amount,
  required this.email,
  required this.dueDate,
  required this.isPaid,
  List<PurchaseEntry>? purchaseHistory,
}) : purchaseHistory = purchaseHistory ?? [];

  String getStatus() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (isPaid == true) {
      return 'Paid';
    }
    if (due.isBefore(today)) {
      return 'Overdue';
    } else if (due.isAtSameMomentAs(today)) {
      return 'Due Today';
    } else {
      return 'Upcoming';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'email': email,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'purchaseHistory': purchaseHistory
    .map((entry) => entry.toMap())
    .toList(),
    };
  }

  factory DebtorModel.fromMap(Map<String, dynamic> map) {
    return DebtorModel(
      name: map['name'],
      amount: map['amount'],
      email: map['email'],
      dueDate: DateTime.parse(map['dueDate']),
      isPaid: map['isPaid']?? false,
      purchaseHistory: (map['purchaseHistory'] as List<dynamic>? ?? [])
    .map(
      (entry) => PurchaseEntry.fromMap(
        Map<String, dynamic>.from(entry as Map),
      ),
    )
    .toList(),
    );
  }
}

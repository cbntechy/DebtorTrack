import 'package:debtortrack/models/purchase_entry.dart';

enum ReminderChannel { email, whatsapp }

class DebtorModel {
  final String name;
  final double amount;
  final String email;
  final String phoneNumber;
  final ReminderChannel preferredChannel;
  final int notificationId;
  final DateTime dueDate;
  final String note;
  bool isPaid;
  final List<PurchaseEntry> purchaseHistory;

  DebtorModel({
    required this.name,
    required this.amount,
    required this.email,
    this.phoneNumber = '',
    this.preferredChannel = ReminderChannel.email,
    int? notificationId,
    required this.dueDate,
    String? note,
    required this.isPaid,
    List<PurchaseEntry>? purchaseHistory,
  }) : notificationId =
           notificationId ??
               DateTime.now().microsecondsSinceEpoch.remainder(2147483647),
       note = note ?? '',
       purchaseHistory = purchaseHistory ?? [];

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
      'phoneNumber': phoneNumber,
      'preferredChannel': preferredChannel.name,
      'notificationId': notificationId,
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'isPaid': isPaid,
      'purchaseHistory': purchaseHistory.map((entry) => entry.toMap()).toList(),
    };
  }

  factory DebtorModel.fromMap(Map<String, dynamic> map) {
    return DebtorModel(
      name: map['name'],
      amount: map['amount'],
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      preferredChannel: ReminderChannel.values.firstWhere(
        (channel) => channel.name == map['preferredChannel'],
        orElse: () => ReminderChannel.email,
      ),
      notificationId: (map['notificationId'] as num?)?.toInt(),
      note: map['note'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate']),
      isPaid: map['isPaid'] ?? false,
      purchaseHistory: (map['purchaseHistory'] as List<dynamic>? ?? [])
          .map(
            (entry) =>
                PurchaseEntry.fromMap(Map<String, dynamic>.from(entry as Map)),
          )
          .toList(),
    );
  }
}

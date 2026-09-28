class DebtorModel {
  final String name;
  final double amount;
  final String email;
  final DateTime dueDate;
 bool isPaid;

  DebtorModel({
    required this.name,
    required this.amount,
    required this.email,
    required this.dueDate,
    required this.isPaid,
  });

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
    };
  }

  factory DebtorModel.fromMap(Map<String, dynamic> map) {
    return DebtorModel(
      name: map['name'],
      amount: map['amount'],
      email: map['email'],
      dueDate: DateTime.parse(map['dueDate']),
      isPaid: map['isPaid']?? false,
    );
  }
}

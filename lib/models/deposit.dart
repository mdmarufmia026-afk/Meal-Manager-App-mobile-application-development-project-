
class Deposit {
  String memberName;
  double amount;
  DateTime date;

  Deposit({
    required this.memberName,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberName': memberName,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Deposit.fromMap(Map<dynamic, dynamic> map) {
    return Deposit(
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'].toString()),
    );
  }
}

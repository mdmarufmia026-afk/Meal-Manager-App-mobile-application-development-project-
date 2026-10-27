class Meal {
  String memberName;
  DateTime date;
  int count;

  Meal({
    required this.memberName,
    required this.date,
    required this.count,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberName': memberName,
      'date': date.toIso8601String(),
      'count': count,
    };
  }

  factory Meal.fromMap(Map<dynamic, dynamic> map) {
    return Meal(
      memberName: map['memberName'] ?? '',
      date: DateTime.parse(map['date']),
      count: map['count'] ?? 0,
    );
  }
}
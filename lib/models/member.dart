class Member {
  String name;
  double deposit;

  Member({
    required this.name,
    this.deposit = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'deposit': deposit,
    };
  }

  factory Member.fromMap(Map<dynamic, dynamic> map) {
    return Member(
      name: map['name'] ?? '',
      deposit: (map['deposit'] ?? 0).toDouble(),
    );
  }
}
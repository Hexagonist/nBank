class TransactionModel {
  final DateTime date;
  final String shop;
  final double amount;
  final bool type; // true = uznanie, false = obciążenie

  TransactionModel({
    required this.date,
    required this.shop,
    required this.amount,
    required this.type, // 
  });

  // Jeśli pobierasz z JSON:
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      date: DateTime.parse(json['date']),
      shop: json['shop'],
      amount: json['amount'],
      type: json['type'], // <-- i tutaj
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'shop': shop,
      'amount': amount,
      'type': type,
    };
  }
}

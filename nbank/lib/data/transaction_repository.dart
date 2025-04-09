import '../models/transaction_model.dart';

class TransactionRepository {
  final List<TransactionModel> _mockedTransactions = [
    TransactionModel(date: DateTime(2025, 1, 2), shop: 'Biedronka', amount: 37.90, type: true),
    TransactionModel(date: DateTime(2025, 1, 14), shop: 'Lidl', amount: 22.50, type: true),
    TransactionModel(date: DateTime(2025, 1, 28), shop: 'Media Markt', amount: 250.00, type: true),
    TransactionModel(date: DateTime(2025, 2, 5), shop: 'Shein', amount: 89.99, type: true),
    TransactionModel(date: DateTime(2025, 2, 12), shop: 'Zara', amount: 130.00, type: true),
    TransactionModel(date: DateTime(2025, 2, 21), shop: 'Bootland', amount: 125.94, type: true),
    TransactionModel(date: DateTime(2025, 3, 3), shop: 'Empik', amount: 59.00, type: true),
    TransactionModel(date: DateTime(2025, 3, 9), shop: 'Rossmann', amount: 45.70, type: true),
    TransactionModel(date: DateTime(2025, 3, 15), shop: 'IKEA', amount: 310.49, type: true),
    TransactionModel(date: DateTime(2025, 3, 26), shop: 'Carrefour', amount: 71.89, type: true),
    TransactionModel(date: DateTime(2025, 4, 2), shop: 'Castorama', amount: 199.99, type: false),
    TransactionModel(date: DateTime(2025, 4, 10), shop: 'Zalando', amount: 140.00, type: false),
    TransactionModel(date: DateTime(2025, 4, 19), shop: 'Tesco', amount: 65.00, type: false),
    TransactionModel(date: DateTime(2025, 5, 1), shop: 'Auchan', amount: 99.99, type: false),
    TransactionModel(date: DateTime(2025, 5, 8), shop: 'Shell', amount: 200.00, type: false),
    TransactionModel(date: DateTime(2025, 5, 17), shop: 'Shein', amount: 79.00, type: false),
    TransactionModel(date: DateTime(2025, 5, 24), shop: 'McDonald\'s', amount: 35.50, type: false),
    TransactionModel(date: DateTime(2025, 6, 3), shop: 'Starbucks', amount: 18.90, type: false),
    TransactionModel(date: DateTime(2025, 6, 12), shop: 'Decathlon', amount: 149.00, type: false),
    TransactionModel(date: DateTime(2025, 6, 29), shop: 'Booking', amount: 420.00, type: false),
];

  Future<List<TransactionModel>> getAllTransactions() async {
    await Future.delayed(Duration(milliseconds: 300)); // symulacja opóźnienia
    return _mockedTransactions;
  }

  Future<void> addTransaction(TransactionModel tx) async {
    _mockedTransactions.add(tx);
  }

  // Dodaj inne metody typu update, delete jak będziesz chciał
}

import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final double amount;
  final DateTime date;
  final String title;
  final String shop;
  final bool type; // true = Uznanie (+), false = Obciążenie (−)

  TransactionModel({
    required this.amount,
    required this.date,
    required this.title,
    required this.shop,
    required this.type,
  });

  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String currentUserId) {
    final isCredit = data['recipientId'] == currentUserId;

    return TransactionModel(
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['timestamp'] as Timestamp).toDate(),
      title: data['title'] ?? '',
      shop: data['recipientName'] ?? '',
      type: isCredit,
    );
  }

  get senderID => null;

  get accountNumber => null;
}

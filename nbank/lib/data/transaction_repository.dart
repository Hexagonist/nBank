import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<TransactionModel>> getAllTransactions() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Brak zalogowanego użytkownika");

    // Transakcje, gdzie użytkownik jest nadawcą
    final senderSnapshot = await _db
        .collection('transactions')
        .where('senderId', isEqualTo: user.uid)
        .get();

    // Transakcje, gdzie użytkownik jest odbiorcą
    final recipientSnapshot = await _db
        .collection('transactions')
        .where('recipientId', isEqualTo: user.uid)
        .get();

    final allDocs = [...senderSnapshot.docs, ...recipientSnapshot.docs];

    return allDocs
        .map((doc) => TransactionModel.fromFirestore(doc.data(), user.uid))
        .toList();
  }
}

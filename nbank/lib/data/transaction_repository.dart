import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<TransactionModel>> getAllTransactions() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Brak zalogowanego użytkownika");

    final snapshot = await _db.collection('transactions').get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc.data(), user.uid))
        .toList();
  }
}

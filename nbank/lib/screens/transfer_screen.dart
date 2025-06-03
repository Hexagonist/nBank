import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../login_screens/pin_lock_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientAccountController = TextEditingController();
  final TextEditingController _transferTitleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _isLoading = false;
  double? _availableBalance;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Brak zalogowanego użytkownika");

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception("Nie znaleziono danych użytkownika");

      setState(() {
        _availableBalance = (doc['balance'] ?? 0).toDouble();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas ładowania danych: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _executeTransfer() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    if (_availableBalance == null || amount > _availableBalance!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Niewystarczające środki')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Brak zalogowanego użytkownika");

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Znajdź odbiorcę po numerze konta
      final recipientQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('accountNumber', isEqualTo: _recipientAccountController.text)
          .limit(1)
          .get();

      if (recipientQuery.docs.isEmpty) {
        throw Exception("Nie znaleziono odbiorcy o podanym rachunku");
      }

      final recipientDoc = recipientQuery.docs.first;
      final recipientRef = recipientDoc.reference;

      // Zrób to w transakcji, aby uniknąć konfliktów i zapewnić spójność
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Pobierz aktualne saldo nadawcy
        final senderSnapshot = await transaction.get(userRef);
        final senderBalance = (senderSnapshot.data()?['balance'] ?? 0).toDouble();

        if (senderBalance < amount) {
          throw Exception("Niewystarczające środki na koncie");
        }

        // Pobierz saldo odbiorcy
        final recipientSnapshot = await transaction.get(recipientRef);
        final recipientBalance = (recipientSnapshot.data()?['balance'] ?? 0).toDouble();

        // Aktualizuj saldo nadawcy i odbiorcy
        transaction.update(userRef, {'balance': senderBalance - amount});
        transaction.update(recipientRef, {'balance': recipientBalance + amount});

        // Opcjonalnie: zapis transakcji w kolekcji 'transactions'
        final transactionRef = FirebaseFirestore.instance.collection('transactions').doc();
        transaction.set(transactionRef, {
          'senderId': user.uid,
          'recipientId': recipientDoc.id,
          'recipientName': _recipientNameController.text,
          'recipientAccount': _recipientAccountController.text,
          'title': _transferTitleController.text,
          'amount': amount,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });

      // Po sukcesie odśwież saldo użytkownika
      await _loadUserBalance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas wykonywania przelewu: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _confirmTransfer() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinLockScreen(
          onPinCorrect: () async {
            Navigator.pop(context); // zamknij ekran PIN
            await _executeTransfer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Przelew zakończono!')),
            );
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientAccountController.dispose();
    _transferTitleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _availableBalance == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nowy przelew')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nowy przelew')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _recipientNameController,
                      decoration: const InputDecoration(labelText: 'Nazwa odbiorcy'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Wpisz nazwę odbiorcy' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _recipientAccountController,
                      decoration: const InputDecoration(labelText: 'Rachunek odbiorcy'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Wpisz rachunek odbiorcy' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _transferTitleController,
                      decoration: const InputDecoration(labelText: 'Tytuł przelewu'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Wpisz tytuł przelewu' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Wolne środki: ${_availableBalance?.toStringAsFixed(2) ?? '0.00'} PLN',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Kwota przelewu'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount <= 0) return 'Wpisz poprawną kwotę';
                        if (_availableBalance != null && amount > _availableBalance!) return 'Niewystarczające środki';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _confirmTransfer,
                      child: const Text('Potwierdź przelew'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

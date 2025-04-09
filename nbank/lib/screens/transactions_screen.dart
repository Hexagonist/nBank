import 'package:flutter/material.dart';
import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../navigation/app_routes.dart';
import 'package:intl/intl.dart';
import '../login_screens/session_menager.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final SessionManager _sessionManager = SessionManager();
  final TransactionRepository _repo = TransactionRepository();
  late Future<List<TransactionModel>> _transactionsFuture;

  String selectedDateFilter = 'Ostatni';
  String selectedTypeFilter = 'Wszystkie';

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _repo.getAllTransactions();
  }

  List<TransactionModel> applyFilters(List<TransactionModel> transactions) {
    return transactions.where((tx) {
      // 🔹 Filtr typu transakcji
      if (selectedTypeFilter == 'Uznania' && tx.type != true) return false;
      if (selectedTypeFilter == 'Obciążenia' && tx.type != false) return false;

      // 🔹 Filtr daty
      final now = DateTime.now();
      final difference = now.difference(tx.date).inDays;

      switch (selectedDateFilter) {
        case 'Ostatni':
          return difference <= 7;
        case 'Miesiąc':
          return difference <= 30;
        case 'Rok':
          return difference <= 365;
        case 'Cały okres':
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _sessionManager.handleUserInteraction,
        onPanDown: (_) => _sessionManager.handleUserInteraction(),
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
        appBar: AppBar(title: Text('Transakcje')),
        body: FutureBuilder<List<TransactionModel>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final allTransactions = snapshot.data ?? [];
            final filteredTransactions = applyFilters(allTransactions);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🔹 Filtry daty
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Filtr daty:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Wrap(
                    spacing: 10,
                    children: ['Ostatni', 'Miesiąc', 'Rok', 'Cały okres']
                        .map((label) => ChoiceChip(
                              label: Text(label),
                              selected: selectedDateFilter == label,
                              onSelected: (_) {
                                setState(() {
                                  selectedDateFilter = label;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Filtry typu
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Typ transakcji:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Wrap(
                    spacing: 10,
                    children: ['Uznania', 'Obciążenia', 'Wszystkie']
                        .map((label) => ChoiceChip(
                              label: Text(label),
                              selected: selectedTypeFilter == label,
                              onSelected: (_) {
                                setState(() {
                                  selectedTypeFilter = label;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Lista transakcji
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        final typeLabel = tx.type ? 'Uznanie' : 'Obciążenie';

                        return ListTile(
                          title: Text(tx.shop),
                          subtitle: Text(
                            '${DateFormat('dd.MM.yyyy').format(tx.date)} • $typeLabel',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Text('${tx.amount.toStringAsFixed(2)} zł'),
                        );
                      },
                    ),
                  ),

                  // 🔹 Przycisk do analizy
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.analysis);
                    },
                    icon: Icon(Icons.bar_chart),
                    label: Text("Wykresy – analizuj wydatki"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

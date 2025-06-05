import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../login_screens/session_menager.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final SessionManager _sessionManager = SessionManager();
  final TransactionRepository _repo = TransactionRepository();

  double _totalBudget = 0.0;
  double _spent = 0.0;
  double _left = 0.0;
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  String selectedTypeFilter = 'Wszystkie';

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    setState(() {
      _loading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final budget = doc.data()?['budget'];
      if (budget != null && budget is num) {
        _totalBudget = budget.toDouble();
      }
    }

    final transactions = await _repo.getAllTransactions();
    final now = DateTime.now();
    double spent = 0.0;
    List<TransactionModel> currentMonthTransactions = [];

    for (var tx in transactions) {
      if (tx.date.year == now.year && tx.date.month == now.month) {
        currentMonthTransactions.add(tx);
        if (tx.amount < 0) spent += tx.amount;
      }
    }

    setState(() {
      _transactions = currentMonthTransactions;
      _spent = spent;
      _left = (_totalBudget - spent).clamp(0, _totalBudget);
      _loading = false;
    });
  }

  List<TransactionModel> applyTypeFilter(List<TransactionModel> transactions) {
    if (selectedTypeFilter == 'Uznania') {
      return transactions.where((tx) => tx.type == true).toList();
    } else if (selectedTypeFilter == 'Obciążenia') {
      return transactions.where((tx) => tx.type == false).toList();
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = applyTypeFilter(_transactions);

    return GestureDetector(
      onTap: _sessionManager.handleUserInteraction,
      onPanDown: (_) => _sessionManager.handleUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budżet'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      "Twój budżet miesięczny: ${_totalBudget.toStringAsFixed(2)} zł",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: _left,
                              color: Colors.green,
                              title: 'Pozostało\n${_left.toStringAsFixed(2)} zł',
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: _spent,
                              color: Colors.red,
                              title: 'Wydano\n${_spent.toStringAsFixed(2)} zł',
                              radius: 80,
                              titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
                    const SizedBox(height: 16),
                    const Text(
                      "Transakcje w tym miesiącu:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? const Center(child: Text("Brak transakcji"))
                          : ListView.builder(
                              itemCount: filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final t = filteredTransactions[index];
                                final typeLabel = t.type ? 'Uznanie' : 'Obciążenie';
                                final sign = t.type ? '+' : '-';
                                return ListTile(
                                  leading: Icon(
                                    t.type ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: t.type ? Colors.green : Colors.red,
                                  ),
                                  title: Text(t.title),
                                  subtitle: Text(
                                    '${DateFormat('dd.MM.yyyy').format(t.date)} • $typeLabel',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  trailing: Text(
                                    '$sign${t.amount.toStringAsFixed(2)} zł',
                                    style: TextStyle(
                                      color: t.type ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
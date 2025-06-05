import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../login_screens/session_menager.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final SessionManager _sessionManager = SessionManager();
  final TransactionRepository _repo = TransactionRepository();

  double _totalBudget = 2000.0; // Możesz pobierać z ustawień użytkownika
  double _spent = 0.0;
  double _left = 0.0;
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
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

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      "Transakcje:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: _transactions.isEmpty
                          ? const Center(child: Text("Brak transakcji"))
                          : ListView.builder(
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final t = _transactions[index];
                                return ListTile(
                                  leading: const Icon(Icons.attach_money),
                                  // title: Text(t.description ?? ''),
                                  trailing: Text("-${t.amount.toStringAsFixed(2)} zł"),
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
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TransactionRepository _repo = TransactionRepository();
  Map<String, double> _monthlyTotals = {};

  @override
  void initState() {
    super.initState();
    _loadMonthlyTotals();
  }

  Future<void> _loadMonthlyTotals() async {
    final transactions = await _repo.getAllTransactions();

    Map<String, double> totals = {};
    for (var tx in transactions) {
      final String month = DateFormat('MMM').format(tx.date);
      totals[month] = (totals[month] ?? 0) + tx.amount;
    }

    setState(() {
      _monthlyTotals = totals;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> months = _monthlyTotals.keys.toList();
    final List<double> values = _monthlyTotals.values.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Analiza wydatków")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _monthlyTotals.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: values.reduce((a, b) => a > b ? a : b) + 20,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < months.length) {
                            return Text(months[index]);
                          } else {
                            return const Text('');
                          }
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    months.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          width: 16,
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

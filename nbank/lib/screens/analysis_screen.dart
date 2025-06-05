import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../data/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../login_screens/session_menager.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final SessionManager _sessionManager = SessionManager();
  final TransactionRepository _repo = TransactionRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionModel>>(
      future: _repo.getAllTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return GestureDetector(
            onTap: _sessionManager.handleUserInteraction,
            onPanDown: (_) => _sessionManager.handleUserInteraction(),
            behavior: HitTestBehavior.translucent,
            child: Scaffold(
              appBar: AppBar(title: const Text("Analiza wydatków")),
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final transactions = snapshot.data!;

        // Rozpoznawanie typu transakcji jak w TransactionsScreen
        final Map<String, double> inflows = {};   // uznania (przychody)
        final Map<String, double> outflows = {};  // obciążenia (wydatki)

        for (var tx in transactions) {
          final String key = '${tx.date.year}-${tx.date.month}';
          // Rozpoznanie na podstawie pola type
          if (tx.type == true) {
            inflows[key] = (inflows[key] ?? 0) + tx.amount.abs();
          } else if (tx.type == false) {
            outflows[key] = (outflows[key] ?? 0) + tx.amount.abs();
          }
        }

        // Zbierz wszystkie miesiące w kolejności chronologicznej
        final allMonths = <String>{};
        for (var tx in transactions) {
          allMonths.add('${tx.date.year}-${tx.date.month}');
        }
        final months = allMonths.toList()
          ..sort((a, b) {
            final ay = int.parse(a.split('-')[0]);
            final am = int.parse(a.split('-')[1]);
            final by = int.parse(b.split('-')[0]);
            final bm = int.parse(b.split('-')[1]);
            return ay != by ? ay.compareTo(by) : am.compareTo(bm);
          });

        String getMonthShort(int year, int month) {
          return DateFormat('MMM', 'pl').format(DateTime(year, month));
        }

        final maxY = [
          ...inflows.values,
          ...outflows.values
        ].fold<double>(0, (prev, el) => el > prev ? el : prev) + 20;

        return GestureDetector(
          onTap: _sessionManager.handleUserInteraction,
          onPanDown: (_) => _sessionManager.handleUserInteraction(),
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            appBar: AppBar(title: const Text("Analiza wydatków")),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: true),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || (value - maxY).abs() < 1) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || (value - maxY).abs() < 1) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < months.length) {
                            final parts = months[index].split('-');
                            final year = int.parse(parts[0]);
                            final month = int.parse(parts[1]);
                            return Text(getMonthShort(year, month));
                          } else {
                            return const Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    months.length,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: outflows[months[i]] ?? 0,
                          width: 14,
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: inflows[months[i]] ?? 0,
                          width: 14,
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                      barsSpace: 4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
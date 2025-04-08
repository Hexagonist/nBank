import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiza wydatków'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Wydatki w czasie',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 200, child: LineChartWidget()),
            const SizedBox(height: 24),
            const Text(
              'Udział kategorii',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 200, child: PieChartWidget()),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            spots: [
              FlSpot(0, 300),
              FlSpot(1, 500),
              FlSpot(2, 400),
              FlSpot(3, 600),
              FlSpot(4, 450),
              FlSpot(5, 700),
              FlSpot(6, 650),
            ],
          ),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, title: 'Jedzenie', color: Colors.red),
          PieChartSectionData(value: 30, title: 'Transport', color: Colors.blue),
          PieChartSectionData(value: 15, title: 'Rozrywka', color: Colors.yellow),
          PieChartSectionData(value: 15, title: 'Inne', color: Colors.green),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 30,
      ),
    );
  }
}

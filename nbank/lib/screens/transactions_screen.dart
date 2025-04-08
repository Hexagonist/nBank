import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transakcje'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text("Tu będzie lista transakcji."),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.analysis);
              },
              icon: Icon(Icons.analytics),
              label: Text('Przejdź do analizy'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

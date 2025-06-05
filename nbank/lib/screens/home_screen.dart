import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../navigation/app_routes.dart';
import '../login_screens/session_menager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final SessionManager _sessionManager = SessionManager();

  String? accountNumber;
  double? balance;
  String? email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionManager.start(context);
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('accountNumber')) {
        setState(() {
          accountNumber = doc['accountNumber'];
          balance = (doc['balance'] ?? 0).toDouble();
          email = doc['email'] ?? '';
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sessionManager.handleUserInteraction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _sessionManager.handleUserInteraction,
      onPanDown: (_) => _sessionManager.handleUserInteraction(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(title: const Text("Ekran główny")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (accountNumber != null) _buildAccountBox(),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.transactions);
                      },
                      child: const Text("Przejdź do transakcji"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _sessionManager.stop();
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: const Text("Wyloguj"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Twoje konto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Numer konta: $accountNumber", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          const Text("Wolne środki", style: TextStyle(fontSize: 16)),
          Text(
            "${balance?.toStringAsFixed(2) ?? '0.00'} PLN",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.transfer);//TU ZMIANA
              },
              child: const Text("Przelej"),
            ),
          ),
        ],
      ),
    );
  }
}

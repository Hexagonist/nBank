import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import 'login_screen.dart';


class PinLockScreen extends StatefulWidget {
  @override
  _PinLockScreenState createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _checkPin() {
    if (loggedInUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Brak zalogowanego użytkownika")),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    if (_pinController.text == loggedInUser!.pin) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Niepoprawny PIN")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Wprowadź PIN")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Aplikacja została zablokowana po bezczynności."),
            SizedBox(height: 12),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: "PIN"),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkPin,
              child: Text("Odblokuj"),
            ),
          ],
        ),
      ),
    );
  }
}

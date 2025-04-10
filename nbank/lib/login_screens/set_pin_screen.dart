import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../user/user.dart';

class SetPinScreen extends StatefulWidget {
  final String email;
  final String password;

  const SetPinScreen({super.key, required this.email, required this.password});

  @override
  _SetPinScreenState createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _setPin() {
    if (_formKey.currentState!.validate()) {
      String pin = _pinController.text;

      // Add the new user with the provided email, password, and pin
      users.add(User(email: widget.email, password: widget.password, pin: pin));

      // Navigate to the login screen
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ustaw PIN")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _pinController,
                decoration: InputDecoration(labelText: "Wprowadź PIN"),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Wprowadź PIN";
                  }
                  if (value.length != 4) {
                    return "PIN musi mieć 4 cyfry";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPinController,
                decoration: InputDecoration(labelText: "Potwierdź PIN"),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Potwierdź PIN";
                  }
                  if (value != _pinController.text) {
                    return "PINy muszą być takie same";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _setPin,
                child: Text("Zatwierdź PIN"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login_screens/set_pin_screen.dart';
import '../navigation/app_routes.dart';
import '../user/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _register() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      bool userExists = users.any((user) => user.email == email);
      
      if (userExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Użytkownik już istnieje")),
        );
      } else {
        // Navigate to the SetPinScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetPinScreen(email: email, password: password),
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rejestracja")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Wprowadź email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Hasło"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Wprowadź hasło";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                child: Text("Zarejestruj się"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';
import '../data/generate_account_number.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  _SetPinScreenState createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String pin = '';
  String confirmPin = '';
  bool isConfirming = false;
  bool isPinVisible = false;

  void _onDigitPressed(int digit) {
    setState(() {
      if ((isConfirming ? confirmPin : pin).length < 4) {
        if (isConfirming) {
          confirmPin += digit.toString();
        } else {
          pin += digit.toString();
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (isConfirming) {
        if (confirmPin.isNotEmpty) {
          confirmPin = confirmPin.substring(0, confirmPin.length - 1);
        }
      } else {
        if (pin.isNotEmpty) {
          pin = pin.substring(0, pin.length - 1);
        }
      }
    });
  }

  void _onSubmit() async {
    if (pin.length != 4 || confirmPin.length != 4) return;

    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PINy się różnią")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nie zalogowano użytkownika")),
      );
      return;
    }

    try {
      final nrb = await generateValidUniqueNRB(); // 🔥 tutaj generujemy unikalny NRB

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'pin': pin,
        'email': user.email,
        'balance': 1000,
        'budget': 1000,
        'accountNumber': nrb, // 💸 zapisujemy numer konta
      });

      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd zapisu: ${e.toString()}")),
      );
    }
}


  Widget _buildPinDots(String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) {
          final isFilled = index < value.length;
          return Container(
            margin: const EdgeInsets.all(6.0),
            width: isPinVisible ? 50 : 16,
            height: isPinVisible ? 50 : 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              color: isFilled
                  ? isPinVisible
                      ? Colors.green
                      : CupertinoColors.activeBlue
                  : CupertinoColors.activeBlue.withOpacity(0.1),
            ),
            child: isPinVisible && isFilled
                ? Center(
                    child: Text(
                      value[index],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildNumberPad() {
    List<Widget> rows = [];
    for (var i = 0; i < 3; i++) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            3,
            (index) {
              int digit = 1 + i * 3 + index;
              return _buildNumButton(digit);
            },
          ),
        ),
      );
    }

    rows.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 64), // empty space
          _buildNumButton(0),
          IconButton(
            onPressed: _onBackspace,
            icon: const Icon(Icons.backspace, size: 28),
          ),
        ],
      ),
    );

    return Column(
      children: rows,
    );
  }

  Widget _buildNumButton(int digit) {
    return TextButton(
      onPressed: () => _onDigitPressed(digit),
      child: Text(
        digit.toString(),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = isConfirming ? confirmPin : pin;

    return Scaffold(
      appBar: AppBar(title: Text("Ustaw PIN")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                isConfirming ? "Potwierdź PIN" : "Wprowadź PIN",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              _buildPinDots(currentPin),
              IconButton(
                onPressed: () {
                  setState(() {
                    isPinVisible = !isPinVisible;
                  });
                },
                icon: Icon(
                  isPinVisible ? Icons.visibility_off : Icons.visibility,
                ),
              ),
              const SizedBox(height: 24),
              _buildNumberPad(),
              const SizedBox(height: 24),
              if (currentPin.length == 4)
                ElevatedButton(
                  onPressed: () {
                    if (isConfirming) {
                      _onSubmit();
                    } else {
                      setState(() {
                        isConfirming = true;
                      });
                    }
                  },
                  child: Text(isConfirming ? "Zatwierdź PIN" : "Dalej"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

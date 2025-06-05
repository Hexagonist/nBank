import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback? onPinCorrect;

  const PinLockScreen({super.key, this.onPinCorrect});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String enteredPin = '';
  bool isPinVisible = false;
  int failedAttempts = 0;
  bool isLocked = false;
  int lockoutSeconds = 3000; // Zmieniony na 30 sekund
  Timer? lockoutTimer;

  Future<String?> fetchUserPin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.data()?['pin'];
  }

  void _checkPin() async {
    if (isLocked) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Brak zalogowanego użytkownika")),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    final correctPin = await fetchUserPin();

    if (correctPin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie udało się pobrać PINu")),
      );
      return;
    }

    if (enteredPin == correctPin) {
      if (widget.onPinCorrect != null) {
        widget.onPinCorrect!();
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      failedAttempts++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Niepoprawny PIN")),
      );

      if (failedAttempts >= 3) {
        _startLockout();
      }
    }
  }

  void _startLockout() {
    setState(() {
      isLocked = true;
      failedAttempts = 0;
    });

    int secondsLeft = lockoutSeconds;

    lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsLeft > 1) {
          secondsLeft--;
        } else {
          lockoutTimer?.cancel();
          lockoutTimer = null;
          isLocked = false;
          secondsLeft = lockoutSeconds;
          enteredPin = '';
        }
      });
    });
  }

  Widget numButton(int number) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: isLocked
            ? null
            : () {
                setState(() {
                  if (enteredPin.length < 4) {
                    enteredPin += number.toString();
                  }
                });
              },
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 50),
            const Center(
              child: Text(
                'Wprowadź PIN',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) {
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    width: isPinVisible ? 50 : 16,
                    height: isPinVisible ? 50 : 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      color: index < enteredPin.length
                          ? isPinVisible
                              ? Colors.green
                              : CupertinoColors.activeBlue
                          : CupertinoColors.activeBlue.withOpacity(0.1),
                    ),
                    child: isPinVisible && index < enteredPin.length
                        ? Center(
                            child: Text(
                              enteredPin[index],
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isPinVisible = !isPinVisible;
                });
              },
              icon: Icon(
                isPinVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.black,
              ),
            ),
            SizedBox(height: isPinVisible ? 50.0 : 8.0),
            for (var i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) => numButton(1 + 3 * i + index),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // puste miejsce zamiast przycisku
                  numButton(0),
                  TextButton(
                    onPressed: isLocked
                        ? null
                        : () {
                            setState(() {
                              if (enteredPin.isNotEmpty) {
                                enteredPin = enteredPin.substring(0, enteredPin.length - 1);
                              }
                            });
                          },
                    child: const Icon(
                      Icons.backspace,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: isLocked
                  ? null
                  : () {
                      setState(() {
                        enteredPin = '';
                      });
                    },
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            TextButton(
              onPressed: _checkPin,
              child: const Text(
                'Odblokuj',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
            if (isLocked)
              Center(
                child: Text(
                  'Zablokowane na $lockoutSeconds sekund',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    lockoutTimer?.cancel();
    super.dispose();
  }
}

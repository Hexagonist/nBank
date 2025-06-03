import 'package:flutter/material.dart';
import '../login_screens/login_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/home_screen.dart';
import '../login_screens/register_screen.dart';
import '../login_screens/pin_lock_screen.dart';
import '../screens/analysis_screen.dart';
import '../login_screens/set_pin_screen.dart';
import '../screens/transfer_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String register = '/register';
  static const String pinlock = '/pinlock';
  static const transactions = '/transactions';
  static const String analysis = '/analysis';
  static const String setPin = '/setpin';
  static const String transfer = '/transfer';
  

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      home: (context) => HomeScreen(),
      register: (context) => RegisterScreen(),
      setPin: (context) => SetPinScreen(),
      pinlock: (context) => PinLockScreen(),
      transactions: (context) => TransactionsScreen(),
      analysis: (context) => AnalysisScreen(),
      transfer: (context) => TransferScreen(),
    };
  }
}

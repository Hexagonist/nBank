import 'package:flutter/material.dart';
import '../login_screens/login_screen.dart';
import '../home_screens/home_screen.dart';
import '../login_screens/register_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String register = '/register';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginScreen(),
      home: (context) => HomeScreen(),
      register: (context) => RegisterScreen()
    };
  }
}

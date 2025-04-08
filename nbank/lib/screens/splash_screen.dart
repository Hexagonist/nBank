import 'package:flutter/material.dart';
import '../navigation/app_routes.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });

    return Scaffold(
      body: Center(
        child: Text('nBank', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}

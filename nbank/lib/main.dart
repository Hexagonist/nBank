import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'navigation/app_routes.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('pl', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme, // poprawka: użyj AppTheme.lightTheme
      darkTheme: AppTheme.darkTheme, // opcjonalnie, jeśli chcesz obsługę dark mode
      initialRoute: AppRoutes.login,
      routes: AppRoutes.getRoutes(),
    );
  }
}
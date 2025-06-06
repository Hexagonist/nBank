import 'dart:async';
import 'package:flutter/widgets.dart';
import '../navigation/app_routes.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Timer? _inactivityTimer;
  final Duration timeout = Duration(seconds: 60); // CZAS DO WYGASNIECIA
  BuildContext? _context;

  void start(BuildContext context) {
    _context = context;
    _resetTimer();
  }

  void stop() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _context = null;
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(timeout, _handleTimeout);
  }

  void handleUserInteraction([_]) {
    if (_context != null) {
      _resetTimer();
    }
  }

  void _handleTimeout() {
    if (_context != null) {
      Navigator.of(_context!).pushReplacementNamed(AppRoutes.pinlock);
    }
  }
}

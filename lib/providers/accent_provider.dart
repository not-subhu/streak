import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccentProvider extends ChangeNotifier {
  Color _accent = const Color(0xFF7C3AED);
  Color get accent => _accent;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt('accent_color');
    if (val != null) _accent = Color(val);
    notifyListeners();
  }

  Future<void> setAccent(Color color) async {
    _accent = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.value);
  }
}

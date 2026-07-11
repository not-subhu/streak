import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

class HabitsProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _statsExpanded = true;
  bool _loaded = false;

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get statsExpanded => _statsExpanded;
  bool get loaded => _loaded;

  int get doneToday => _habits.where((h) => h.isDoneToday).length;
  int get totalHabits => _habits.length;

  int get bestCurrentStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('habits_v1');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _habits = list.map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
    }
    _statsExpanded = prefs.getBool('stats_expanded') ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habits_v1', jsonEncode(_habits.map((h) => h.toJson()).toList()));
  }

  Future<void> addHabit({required String name, required String icon, required int color}) async {
    _habits.add(Habit(id: const Uuid().v4(), name: name, icon: icon, color: color));
    notifyListeners();
    await _save();
  }

  Future<void> toggleToday(String id) async {
    final h = _habits.firstWhere((h) => h.id == id);
    h.toggleToday();
    notifyListeners();
    await _save();
  }

  // Toggle completion for any specific date key "yyyy-MM-dd"
  Future<void> toggleDate(String id, String dateKey) async {
    final h = _habits.firstWhere((h) => h.id == id);
    if (h.completions[dateKey] == true) {
      h.completions.remove(dateKey);
    } else {
      h.completions[dateKey] = true;
    }
    notifyListeners();
    await _save();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> updateHabit(String id, {String? name, String? icon, int? color}) async {
    final idx = _habits.indexWhere((h) => h.id == id);
    if (idx == -1) return;
    _habits[idx] = _habits[idx].copyWith(name: name, icon: icon, color: color);
    notifyListeners();
    await _save();
  }

  Future<void> reorderHabits(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final h = _habits.removeAt(oldIndex);
    _habits.insert(newIndex, h);
    notifyListeners();
    await _save();
  }

  Future<void> toggleStatsExpanded() async {
    _statsExpanded = !_statsExpanded;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stats_expanded', _statsExpanded);
    notifyListeners();
  }
}

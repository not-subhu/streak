import 'dart:convert';

class Habit {
  final String id;
  String name;
  String icon; // emoji string
  int color; // ARGB int
  Map<String, bool> completions; // "yyyy-MM-dd" -> true

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    Map<String, bool>? completions,
  }) : completions = completions ?? {};

  String get todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get isDoneToday => completions[todayKey] == true;

  void toggleToday() {
    if (isDoneToday) {
      completions.remove(todayKey);
    } else {
      completions[todayKey] = true;
    }
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    // Start from today if done, else yesterday
    int offset = isDoneToday ? 0 : 1;
    while (streak < 3650) {
      final d = now.subtract(Duration(days: offset + streak));
      final k = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (completions[k] != true) break;
      streak++;
    }
    return streak;
  }

  int get longestStreak {
    if (completions.isEmpty) return 0;
    final sorted = completions.keys.toList()..sort();
    int longest = 1, current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      if (curr.difference(prev).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  int get totalCompletions => completions.length;

  double completionRate(int days) {
    final now = DateTime.now();
    int done = 0;
    for (int i = 0; i < days; i++) {
      final d = now.subtract(Duration(days: i));
      final k = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (completions[k] == true) done++;
    }
    return done / days;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'completions': completions,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] as String,
    name: json['name'] as String,
    icon: json['icon'] as String,
    color: json['color'] as int,
    completions: (json['completions'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as bool)) ??
        {},
  );

  Habit copyWith({String? name, String? icon, int? color}) => Habit(
    id: id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    completions: completions,
  );
}

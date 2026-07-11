import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/habits_provider.dart';
import 'providers/accent_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitsProvider()..load()),
        ChangeNotifierProvider(create: (_) => AccentProvider()..load()),
      ],
      child: const StreaksApp(),
    ),
  );
}

class StreaksApp extends StatelessWidget {
  const StreaksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AccentProvider>().accent;
    return MaterialApp(
      title: 'Streaks',
      theme: AppTheme.build(accent),
      debugShowCheckedModeBanner: false,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  int _index = 0;

  static const _screens = [HomeScreen(), StatsScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AccentProvider>().accent;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
        ),
        child: NavigationBar(
          backgroundColor: AppTheme.surface,
          indicatorColor: accent.withOpacity(0.15),
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view_rounded, color: accent),
              label: 'Habits',
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_rounded),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: accent),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: const Icon(Icons.tune_rounded),
              selectedIcon: Icon(Icons.tune_rounded, color: accent),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

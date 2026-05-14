import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/user_profile.dart';
import 'services/settings_service.dart';
import 'services/migration_service.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());

  // Executa migração se necessário
  await MigrationService().runMigrationIfNeeded();

  runApp(const LocalVaultApp());
}

class LocalVaultApp extends StatefulWidget {
  const LocalVaultApp({super.key});

  @override
  State<LocalVaultApp> createState() => _LocalVaultAppState();
}

class _LocalVaultAppState extends State<LocalVaultApp> {
  final _settingsService = SettingsService();
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final darkMode = await _settingsService.getDarkMode();
    setState(() => _darkMode = darkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalVault',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: MainScaffold(
        onDarkModeChanged: (value) {
          setState(() => _darkMode = value);
        },
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final Function(bool) onDarkModeChanged;
  const MainScaffold({super.key, required this.onDarkModeChanged});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      const ProfileScreen(),
      SettingsScreen(onDarkModeChanged: widget.onDarkModeChanged),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalVault'),
        centerTitle: false,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: Icon(
        //       Icons.storage_outlined,
        //       color: Theme.of(context).colorScheme.primary,
        //     ),
        //   ),
        // ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock),
            label: 'Token',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}

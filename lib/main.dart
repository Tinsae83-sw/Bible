import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/marked_verses_screen.dart';
import 'services/settings_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsService(),
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          final baseTheme =
              settings.darkMode ? ThemeData.dark() : ThemeData.light();

          return MaterialApp(
            title: 'Holy Bible App',
            debugShowCheckedModeBanner: false,
            theme: baseTheme.copyWith(
              textTheme: baseTheme.textTheme.copyWith(
                bodyMedium: TextStyle(
                  fontFamily: settings.fontFamily,
                  fontSize: settings.fontSize,
                ),
              ),
            ),
            home: BrightnessFilter(
              brightness: settings.brightness,
              child: const MainNavigation(),
            ),
          );
        },
      ),
    );
  }
}

class BrightnessFilter extends StatelessWidget {
  final double brightness;
  final Widget child;

  const BrightnessFilter({
    required this.brightness,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(1.0 - brightness),
        BlendMode.srcOver,
      ),
      child: child,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const HomeScreen(),
      const MarkedVersesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Marked Verses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }
}

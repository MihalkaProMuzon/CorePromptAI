// Импорт основных виджетов Flutter
import 'package:flutter/material.dart';
// Импорт экранов
import 'chat_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

// Главный экран с нижней навигацией
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // Текущий индекс выбранной вкладки
  int _currentIndex = 0;

  // Список экранов для отображения
  final List<Widget> _screens = const [
    ChatScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack сохраняет состояние всех экранов
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Нижняя навигационная панель
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF262626),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

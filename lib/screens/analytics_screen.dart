// Импорт основных виджетов Flutter
import 'package:flutter/material.dart';
// Импорт экранов статистики
import 'stats_screen.dart';
import 'cost_chart_screen.dart';

// Экран аналитики с вкладками
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF262626),
          title: const Text('Аналитика'),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                text: 'Статистика',
                icon: Icon(Icons.bar_chart, size: 20),
              ),
              Tab(
                text: 'Графики',
                icon: Icon(Icons.show_chart, size: 20),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            StatsScreen(),
            CostChartScreen(),
          ],
        ),
      ),
    );
  }
}

// Импорт основных виджетов Flutter
import 'package:flutter/material.dart';
// Импорт для работы с провайдерами состояния
import 'package:provider/provider.dart';
// Импорт библиотеки для графиков
import 'package:fl_chart/fl_chart.dart';
// Импорт для форматирования дат
import 'package:intl/intl.dart';
// Импорт провайдера чата
import '../providers/chat_provider.dart';
// Импорт модели сообщения
import '../models/message.dart';

// Экран графиков стоимости
class CostChartScreen extends StatelessWidget {
  const CostChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, provider, child) {
        final messages = provider.messages;

        // Подготовить данные для графика
        final chartData = _prepareChartData(messages);

        if (chartData.isEmpty) {
          return const Center(
            child: Text(
              'Нет данных для отображения',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // График расходов по дням
            Card(
              color: const Color(0xFF333333),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.show_chart, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Расходы по дням',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: LineChart(
                        _buildLineChartData(chartData, provider.baseUrl),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Список расходов по моделям
            _buildModelCostList(messages, provider.baseUrl),
          ],
        );
      },
    );
  }

  // Подготовка данных для графика
  Map<DateTime, double> _prepareChartData(List<ChatMessage> messages) {
    final Map<DateTime, double> dailyCosts = {};

    for (final msg in messages) {
      if (msg.cost != null && msg.cost! > 0) {
        final date = DateTime(
          msg.timestamp.year,
          msg.timestamp.month,
          msg.timestamp.day,
        );
        dailyCosts[date] = (dailyCosts[date] ?? 0) + msg.cost!;
      }
    }

    return dailyCosts;
  }

  // Построение данных для LineChart
  LineChartData _buildLineChartData(
      Map<DateTime, double> dailyCosts, String? baseUrl) {
    final sortedDates = dailyCosts.keys.toList()..sort();

    if (sortedDates.isEmpty) {
      return LineChartData();
    }

    // Создать точки для графика
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final cost = dailyCosts[date]!;
      spots.add(FlSpot(i.toDouble(), cost));
    }

    // Определить валюту
    final isVsetgpt = baseUrl?.contains('vsegpt.ru') == true;
    final currency = isVsetgpt ? '₽' : '\$';

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: null,
        verticalInterval: null,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white12,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final index = value.toInt();
              if (index < 0 || index >= sortedDates.length) {
                return const Text('');
              }
              final date = sortedDates[index];
              final formatter = DateFormat('dd.MM');
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  formatter.format(date),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: null,
            reservedSize: 42,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                '$currency${value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white12),
      ),
      minX: 0,
      maxX: (sortedDates.length - 1).toDouble(),
      minY: 0,
      maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.blue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.2),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => const Color(0xFF262626),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              if (index < 0 || index >= sortedDates.length) {
                return null;
              }
              final date = sortedDates[index];
              final formatter = DateFormat('dd.MM.yyyy');
              return LineTooltipItem(
                '${formatter.format(date)}\n$currency${barSpot.y.toStringAsFixed(4)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  // Построение списка расходов по моделям
  Widget _buildModelCostList(List<ChatMessage> messages, String? baseUrl) {
    // Группировка по моделям
    final Map<String, double> modelCosts = {};

    for (final msg in messages) {
      if (msg.modelId != null && msg.cost != null && msg.cost! > 0) {
        modelCosts[msg.modelId!] = (modelCosts[msg.modelId!] ?? 0) + msg.cost!;
      }
    }

    if (modelCosts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Сортировка по убыванию стоимости
    final sortedModels = modelCosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Определить валюту
    final isVsetgpt = baseUrl?.contains('vsegpt.ru') == true;
    final currency = isVsetgpt ? '₽' : '\$';

    // Рассчитать общую стоимость
    final totalCost =
        sortedModels.fold<double>(0, (sum, entry) => sum + entry.value);

    return Card(
      color: const Color(0xFF333333),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Расходы по моделям',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Всего: $currency${totalCost.toStringAsFixed(4)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sortedModels.map((entry) {
              final percentage =
                  (entry.value / totalCost * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '$currency${entry.value.toStringAsFixed(4)} ($percentage%)',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / totalCost,
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

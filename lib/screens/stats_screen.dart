// Импорт основных виджетов Flutter
import 'package:flutter/material.dart';
// Импорт для работы с провайдерами состояния
import 'package:provider/provider.dart';
// Импорт провайдера чата
import '../providers/chat_provider.dart';
// Импорт сервиса базы данных
import '../services/database_service.dart';

// Экран статистики
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseService().getStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки статистики: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final stats = snapshot.data ?? {};
        final totalMessages = stats['total_messages'] ?? 0;
        final totalTokens = stats['total_tokens'] ?? 0;
        final modelUsage =
            stats['model_usage'] as Map<String, Map<String, int>>? ?? {};

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Card: Общая статистика
            _buildStatCard(
              title: 'Общая статистика',
              icon: Icons.analytics,
              color: Colors.blue,
              children: [
                _buildStatRow(
                  icon: Icons.message,
                  label: 'Всего сообщений',
                  value: totalMessages.toString(),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  icon: Icons.token,
                  label: 'Всего токенов',
                  value: totalTokens.toString(),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  icon: Icons.calculate,
                  label: 'Среднее токенов/сообщение',
                  value: totalMessages > 0
                      ? (totalTokens / totalMessages).toStringAsFixed(1)
                      : '0',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Card: Баланс
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return _buildStatCard(
                  title: 'Баланс',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  children: [
                    _buildStatRow(
                      icon: Icons.credit_card,
                      label: 'Текущий баланс',
                      value: provider.balance,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Card: Использование по моделям
            if (modelUsage.isNotEmpty)
              _buildStatCard(
                title: 'Использование по моделям',
                icon: Icons.model_training,
                color: Colors.orange,
                children: modelUsage.entries.map((entry) {
                  final modelId = entry.key;
                  final count = entry.value['count'] ?? 0;
                  final tokens = entry.value['tokens'] ?? 0;
                  final avgTokens =
                      count > 0 ? (tokens / count).toStringAsFixed(1) : '0';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          modelId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.message,
                                size: 12, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text(
                              'Сообщений: $count',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.token,
                                size: 12, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text(
                              'Токенов: $tokens',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calculate,
                                size: 12, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text(
                              'Среднее: $avgTokens токенов/сообщение',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  // Построение карточки статистики
  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
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
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // Построение строки статистики
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

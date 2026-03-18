// Импорт основных виджетов Flutter
import 'dart:math';
import 'package:flutter/material.dart';
// Импорт для работы с провайдерами состояния
import 'package:provider/provider.dart';
// Импорт SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';
// Импорт провайдера чата
import '../providers/chat_provider.dart';
// Импорт сервиса базы данных
import '../services/database_service.dart';

// Экран настроек
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentProvider = 'openrouter';
  String _apiKey = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Загрузка настроек из SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentProvider = prefs.getString('api_provider') ?? 'openrouter';
        _apiKey = prefs.getString('api_key') ?? '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Сохранение настроек
  Future<void> _saveSettings() async {
    if (_apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите API ключ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Показать индикатор загрузки
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_provider', _currentProvider);
      await prefs.setString('api_key', _apiKey);

      // Определить baseUrl по провайдеру
      final baseUrl = _currentProvider == 'openrouter'
          ? 'https://openrouter.ai/api/v1'
          : 'https://api.vsegpt.ru/v1';

      // Пересоздать клиент через ChatProvider
      if (mounted) {
        await context.read<ChatProvider>().reinitializeClient(_apiKey, baseUrl);

        // Закрыть индикатор загрузки
        if (mounted) {
          Navigator.pop(context);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Настройки сохранены и применены.\nМодели и баланс обновлены.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Закрыть индикатор загрузки
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сохранения: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1E1E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF262626),
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          // Секция: API Настройки
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'API Настройки',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          RadioListTile<String>(
            title:
                const Text('OpenRouter', style: TextStyle(color: Colors.white)),
            subtitle: const Text('api.openrouter.ai',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: 'openrouter',
            groupValue: _currentProvider,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _currentProvider = value!);
            },
          ),

          RadioListTile<String>(
            title: const Text('VSEGPT', style: TextStyle(color: Colors.white)),
            subtitle: const Text('api.vsegpt.ru',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: 'vsegpt',
            groupValue: _currentProvider,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() => _currentProvider = value!);
            },
          ),

          ListTile(
            leading: const Icon(Icons.key, color: Colors.white70),
            title:
                const Text('API Ключ', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              _apiKey.isEmpty
                  ? 'Не установлен'
                  : '${_apiKey.substring(0, min(8, _apiKey.length))}...',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(Icons.edit, color: Colors.white54, size: 20),
            onTap: () => _showApiKeyDialog(),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Применить настройки'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const Divider(color: Colors.white12),

          // Секция: Данные
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Данные',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.save_alt, color: Colors.white70),
            title: const Text('Экспорт истории',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Сохранить историю сообщений в JSON',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 16),
            onTap: () async {
              final path =
                  await context.read<ChatProvider>().exportMessagesAsJson();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('История сохранена в:\n$path',
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.description, color: Colors.white70),
            title: const Text('Скачать логи',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Экспорт отладочных логов',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 16),
            onTap: () async {
              final path = await context.read<ChatProvider>().exportLogs();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Логи сохранены в:\n$path',
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Очистить историю',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Удалить все сообщения из базы данных',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios,
                color: Colors.red, size: 16),
            onTap: () => _showClearDialog(),
          ),

          const Divider(color: Colors.white12),

          // Секция: О приложении
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'О приложении',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const ListTile(
            leading: Icon(Icons.info, color: Colors.white70),
            title: Text('Версия', style: TextStyle(color: Colors.white)),
            subtitle: Text('1.0.0',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),

          const ListTile(
            leading: Icon(Icons.code, color: Colors.white70),
            title:
                Text('AI Chat Flutter', style: TextStyle(color: Colors.white)),
            subtitle: Text('Чат с AI моделями через OpenRouter и VSEGPT',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Диалог ввода API ключа
  void _showApiKeyDialog() {
    final controller = TextEditingController(text: _apiKey);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: const Text('API Ключ', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите API ключ',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          obscureText: true,
          maxLines: 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _apiKey = controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Диалог подтверждения очистки истории
  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF333333),
        title: const Text('Очистить историю',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Вы уверены? Это действие нельзя отменить.\n\nВсе сообщения будут удалены из базы данных.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DatabaseService().clearHistory();
                await context.read<ChatProvider>().clearHistory();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('История очищена'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Очистить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

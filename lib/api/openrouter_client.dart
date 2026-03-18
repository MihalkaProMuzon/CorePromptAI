// Import JSON library
import 'dart:convert';
// Import HTTP client
import 'package:http/http.dart' as http;
// Import Flutter core classes
import 'package:flutter/foundation.dart';
// Import package for working with .env files
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_model.dart';

// Класс клиента для работы с API OpenRouter
class OpenRouterClient {
  // API ключ для авторизации
  String? apiKey;
  // Базовый URL API
  String? baseUrl;
  // Заголовки HTTP запросов
  Map<String, String> headers;

  // Единственный экземпляр класса (Singleton)
  static final OpenRouterClient _instance = OpenRouterClient._internal();

  // Фабричный метод для получения экземпляра
  factory OpenRouterClient() {
    return _instance;
  }

  // Приватный конструктор для реализации Singleton
  OpenRouterClient._internal()
      : apiKey = null,
        baseUrl = null,
        headers = {};

  Future<void> initialize() async {
    await _initializeClient();
  }

  // Метод инициализации клиента
  Future<void> _initializeClient() async {
    try {
      if (kDebugMode) {
        print('Initializing OpenRouterClient...');
      }

      // Попытка загрузить из SharedPreferences
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final savedApiKey = prefs.getString('api_key');
        final savedProvider = prefs.getString('api_provider');

        if (savedApiKey != null && savedApiKey.isNotEmpty) {
          apiKey = savedApiKey;
          baseUrl = savedProvider == 'vsegpt'
              ? 'https://api.vsegpt.ru/v1'
              : 'https://openrouter.ai/api/v1';

          if (kDebugMode) {
            print('Loaded credentials from SharedPreferences');
            print('Provider: $savedProvider');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Could not load from SharedPreferences: $e');
        }
      }

      // Fallback к .env если нет в SharedPreferences
      if (apiKey == null || apiKey!.isEmpty) {
        apiKey = dotenv.env['OPENROUTER_API_KEY'];
        baseUrl = dotenv.env['BASE_URL'];

        if (kDebugMode) {
          print('Using credentials from .env');
        }
      }

      // Проверка наличия API ключа
      if (apiKey == null || apiKey!.isEmpty) {
        throw Exception('OpenRouter API key not found');
      }
      // Проверка наличия базового URL
      if (baseUrl == null || baseUrl!.isEmpty) {
        throw Exception('BASE_URL not found');
      }

      // Обновление заголовков
      headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'X-Title': 'AI Chat Flutter',
      };

      if (kDebugMode) {
        print('Base URL: $baseUrl');
        print('OpenRouterClient initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing OpenRouterClient: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  // Метод обновления credentials
  Future<void> updateCredentials(String newApiKey, String newBaseUrl) async {
    try {
      if (kDebugMode) {
        print('Updating OpenRouterClient credentials...');
        print('New Base URL: $newBaseUrl');
      }

      // Обновление полей
      apiKey = newApiKey;
      baseUrl = newBaseUrl;

      // Пересоздание заголовков
      headers = {
        'Authorization': 'Bearer $newApiKey',
        'Content-Type': 'application/json',
        'X-Title': 'AI Chat Flutter',
      };

      if (kDebugMode) {
        print('Credentials updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating credentials: $e');
      }
      rethrow;
    }
  }

  // Метод получения списка доступных моделей
  Future<List<AIModel>> getModels() async {
    // Ждем данные если их нет
    if (apiKey == null ||
        apiKey!.isEmpty ||
        baseUrl == null ||
        baseUrl!.isEmpty) {
      await initialize();
    }

    try {
      // Выполнение GET запроса для получения моделей
      final response = await http.get(
        Uri.parse('$baseUrl/models'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Models response status: ${response.statusCode}');
        print('Models response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Парсинг данных о моделях
        final modelsData = json.decode(response.body);
        if (modelsData['data'] != null) {
          return (modelsData['data'] as List)
              .map((model) => AIModel.fromApi(model))
              .toList();
        }
        throw Exception('Invalid API response format');
      } else {
        // Возвращение моделей по умолчанию, если API недоступен
        return [
          AIModel(
            id: 'deepseek-coder',
            name: 'DeepSeek',
            promptPrice: 0,
            completionPrice: 0,
            contextLength: 0,
          ),
        ];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting models: $e');
      }
      // Возвращение моделей по умолчанию в случае ошибки
      return [
        AIModel(
          id: 'deepseek-coder',
          name: 'DeepSeek',
          promptPrice: 0,
          completionPrice: 0,
          contextLength: 0,
        ),
      ];
    }
  }

  // Метод отправки сообщения через API
  Future<Map<String, dynamic>> sendMessage(String message, String model) async {
    // Ждем данные если их нет
    if (apiKey == null ||
        apiKey!.isEmpty ||
        baseUrl == null ||
        baseUrl!.isEmpty) {
      await initialize();
    }

    try {
      // Подготовка данных для отправки
      final data = {
        'model': model, // Модель для генерации ответа
        'messages': [
          {'role': 'user', 'content': message} // Сообщение пользователя
        ],
        'max_tokens': int.parse(dotenv.env['MAX_TOKENS'] ??
            '1000'), // Максимальное количество токенов
        'temperature': double.parse(
            dotenv.env['TEMPERATURE'] ?? '0.7'), // Температура генерации
        'stream': false, // Отключение потоковой передачи
      };

      if (kDebugMode) {
        print('Sending message to API: ${json.encode(data)}');
      }

      // Выполнение POST запроса
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: headers,
        body: json.encode(data),
      );

      if (kDebugMode) {
        print('Message response status: ${response.statusCode}');
        print('Message response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Успешный ответ
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return responseData;
      } else {
        // Обработка ошибки
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'error': errorData['error']?['message'] ?? 'Unknown error occurred'
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Метод получения текущего баланса
  Future<String> getBalance() async {
    // Ждем данные если их нет
    if (apiKey == null ||
        apiKey!.isEmpty ||
        baseUrl == null ||
        baseUrl!.isEmpty) {
      await initialize();
    }

    try {
      // Выполнение GET запроса для получения баланса
      final response = await http.get(
        Uri.parse(baseUrl?.contains('vsegpt.ru') == true
            ? '$baseUrl/balance'
            : '$baseUrl/credits'),
        headers: headers,
      );

      if (kDebugMode) {
        print('Balance response status: ${response.statusCode}');
        print('Balance response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Парсинг данных о балансе
        final data = json.decode(response.body);
        if (data != null && data['data'] != null) {
          if (baseUrl?.contains('vsegpt.ru') == true) {
            final credits =
                double.tryParse(data['data']['credits'].toString()) ??
                    0.0; // Доступно средств
            return '${credits.toStringAsFixed(2)}₽'; // Расчет доступного баланса
          } else {
            final credits = data['data']['total_credits'] ?? 0; // Общие кредиты
            final usage =
                data['data']['total_usage'] ?? 0; // Использованные кредиты

            final value = credits - usage;
            if (value < 0.01) {
              return '\$${value.toStringAsFixed(6)}';
            } else {
              return '\$${value.toStringAsFixed(2)}';
            }
          }
        }
      }
      return baseUrl?.contains('vsegpt.ru') == true
          ? '0.00₽'
          : '\$0.00'; // Возвращение нулевого баланса по умолчанию
    } catch (e) {
      if (kDebugMode) {
        print('Error getting balance: $e');
      }
      return 'Error'; // Возвращение ошибки в случае исключения
    }
  }

  // Метод форматирования цен
  String formatPricing(double pricing) {
    try {
      if (baseUrl?.contains('vsegpt.ru') == true) {
        return '${pricing.toStringAsFixed(3)}₽/K';
      } else {
        return '\$${(pricing * 1000000).toStringAsFixed(3)}/M';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting pricing: $e');
      }
      return '0.00';
    }
  }
}

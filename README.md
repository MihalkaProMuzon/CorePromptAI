# 🚀 CorePromptAI — AI Chat Client

CorePromptAI — это мультиплатформенное приложение (Flutter) для общения с языковыми моделями через OpenRouter и VSEGPT с поддержкой аналитики, статистики и локального хранения данных.

---

## ✨ Основные возможности

### 💬 Чат с AI
- Поддержка различных моделей (OpenRouter / VSEGPT)
- Выбор модели в реальном времени
- Отображение:
  - токенов
  - стоимости
  - используемой модели
- Копирование сообщений

---

### ⚙️ Настройки API
- Выбор провайдера:
  - OpenRouter
  - VSEGPT
- Ввод и хранение API ключа
- Переключение без перезапуска приложения

---

### 📊 Аналитика
- Общая статистика:
  - количество сообщений
  - токены
  - средние значения
- Использование моделей
- Баланс аккаунта
- График расходов по дням

---

### 💾 Работа с данными
- Локальное хранение (SQLite)
- Автоматическое сохранение истории
- Экспорт истории в JSON
- Экспорт логов
- Очистка данных

---

### 🎨 Интерфейс
- Темная тема
- BottomNavigation (3 экрана):
  - Chat
  - Analytics
  - Settings
- Адаптивный UI

---

## 🏗️ Архитектура проекта

```

lib/
├── api/
│   └── openrouter_client.dart
├── models/
│   ├── message.dart
│   └── ai_model.dart
├── providers/
│   └── chat_provider.dart
├── services/
│   ├── database_service.dart
│   └── analytics_service.dart
├── screens/
│   ├── main_navigation.dart
│   ├── chat_screen.dart
│   ├── analytics_screen.dart
│   ├── stats_screen.dart
│   ├── cost_chart_screen.dart
│   └── settings_screen.dart
└── main.dart

````

---

## 🧠 Технологии

- Flutter / Dart
- Provider (state management)
- SQLite (sqflite)
- fl_chart (графики)
- HTTP API (OpenRouter / VSEGPT)

---

## 🔌 Поддержка API

### OpenRouter
- Валюта: $
- Широкий выбор моделей
- Универсальный API

### VSEGPT
- Валюта: ₽
- Оптимизация под РФ
- Простая тарификация

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/your-repo/CorePromptAI.git
cd CorePromptAI
flutter pub get
flutter run
````

---

## ⚙️ Настройка

Все настройки выполняются **внутри приложения**:

1. Откройте вкладку **Settings**
2. Выберите провайдера
3. Введите API ключ
4. Нажмите "Применить"

---

## 📱 Поддерживаемые платформы

* Android ✅
* Windows ✅
* Linux (частично)
* iOS (не тестировалось)

---

## 📦 Сборка

```bash
flutter build apk
```

APK:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📌 Особенности

* Единый клиент для разных API
* Переключение провайдера без перезапуска
* Реальная аналитика использования
* Локальное хранение без облака

---

## 📄 Лицензия

Apache License 2.0

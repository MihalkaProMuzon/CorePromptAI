# ⚙️ Установка CorePromptAI

## 📋 Требования

### Общие
- Flutter SDK (рекомендуется 3.x+)
- Git
- VS Code или Android Studio

Проверка:
```bash
flutter doctor
```

---

### Android

* Android Studio
* Android SDK
* JDK 17+

---

### Windows (опционально)

* Windows 10+
* Visual Studio с компонентом:

  * Desktop development with C++

---

## 🚀 Установка проекта

```bash
git clone https://github.com/your-repo/CorePromptAI.git
cd CorePromptAI
flutter pub get
```

---

## ▶️ Запуск приложения

### Android (рекомендуется)

#### 1. Подключите устройство или запустите эмулятор

Проверка:

```bash
flutter devices
```

---

#### 2. Запуск:

```bash
flutter run
```

---

### Windows

```bash
flutter run -d windows
```

---

## 📱 Запуск на реальном устройстве

1. Включите режим разработчика:

   * Настройки → О телефоне → Номер сборки (7 раз)

2. Включите:

   * USB Debugging
   * Install via USB (для Xiaomi обязательно)

3. Подключите телефон

4. Подтвердите доступ

```bash
flutter run
```

---

## ⚙️ Настройка приложения (ВАЖНО)

После запуска необходимо вручную настроить API:

1. Перейдите в **Settings**
2. Выберите провайдера:

   * OpenRouter
   * VSEGPT
3. Введите API ключ
4. Нажмите **"Применить"**

---

## 📦 Сборка APK

```bash
flutter build apk
```

Файл:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Проверка работы

Если всё настроено правильно:

* загружается список моделей
* отображается баланс
* можно отправлять сообщения
* появляется статистика

---

## 🐞 Частые проблемы

### ❌ Устройство не найдено

```bash
adb devices
```

---

### ❌ INSTALL_FAILED_USER_RESTRICTED

Решение:

* включить Install via USB
* разрешить установку
* переподключить устройство

---

### ❌ API не работает

Проверь:

* введён ли ключ
* нажата ли кнопка "Применить"
* выбран ли правильный провайдер

---

## 📌 Итог

После выполнения всех шагов приложение полностью готово к работе.
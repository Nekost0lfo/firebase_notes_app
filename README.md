# Отчет по практическому занятию №8
## Работа с базами данных. Подключение приложения к Firebase
### Батов Даниил, ЭФБО-10-23

### Введение
В рамках практического занятия было разработано Flutter-приложение для управления заметками с использованием Firebase Firestore. Приложение реализует базовые CRUD-операции (создание, чтение, обновление, удаление) и синхронизацию данных в реальном времени.

### Шаги выполнения

#### 1. Подготовка проекта Flutter
Создан новый проект Flutter с помощью команды:
```
flutter create firebase_notes_app
```
Проект успешно компилируется и запускается на эмуляторе или устройстве.

**Контрольная точка 1:** проект компилируется и запускается

#### 2. Создание проекта Firebase и привязка через FlutterFire CLI
Для подключения Firebase использован FlutterFire CLI:
- Установлен FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Выполнена команда `flutterfire configure` для авторизации и выбора проекта Firebase. Был создан проект в Firebase Console и подключены платформы (Android, iOS, Web).
- В корне проекта автоматически создан файл `lib/firebase_options.dart`.

**Контрольная точка 2:** в проекте есть firebase_options.dart, сборка проходит без ошибок

#### 3. Установка пакетов и инициализация Firebase
В файл `pubspec.yaml` добавлены зависимости:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.4
```
Выполнена команда `flutter pub get` для установки пакетов.

Инициализация Firebase выполнена в `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NotesApp());
}
```

**Контрольная точка 3:** приложение запускается без ошибок и не падает на старте

#### 4. Настройка Cloud Firestore и правил безопасности
В консоли Firebase создана коллекция `notes`. Структура документа:
- title (string)
- content (string)
- createdAt (timestamp)
- updatedAt (timestamp)

На время разработки установлены правила безопасности, разрешающие чтение и запись без аутентификации:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Контрольная точка 4:** можно создавать документы через консоль Firebase

#### 5. Реализация CRUD-операций
Создан файл `lib/notes_page.dart`, в котором реализован экран для управления заметками. Основные функции:

- `_createNote()` - создание новой заметки
- `_updateNote()` - обновление существующей заметки  
- `_deleteNote()` - удаление заметки
- `_openCreateDialog()` - диалог создания заметки
- `_openEditDialog()` - диалог редактирования заметки

Для отображения списка заметок в реальном времени использован `StreamBuilder`.

### Скриншоты контрольных этапов

1. **Настроенный проект Firebase**  
  <img width="1800" height="973" alt="image" src="https://github.com/user-attachments/assets/ac2f5a6d-227b-4dca-9ef0-e2f2dfe3faa0" />


2. **Запущенное приложение с отображением списка**  
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/eaf8cbdb-cdd3-4e4b-b021-65f765ce1ed9" />


3. **После добавления заметки**  
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/adfdd03a-9ca3-4698-8006-d6bbf761a510" />

<img width="1529" height="802" alt="image" src="https://github.com/user-attachments/assets/169b69e5-3b94-4ae7-8219-40c694561e0c" />



4. **После редактирования заметки**  
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/ece4cb44-2021-4b07-94c6-96d149dbe0d8" />

<img width="1532" height="712" alt="image" src="https://github.com/user-attachments/assets/e82c5cc9-0276-4c38-a92c-f85a63d64e3e" />



5. **После удаления заметки**  
<img width="576" height="1280" alt="image" src="https://github.com/user-attachments/assets/a6935f19-653e-413e-9129-730c810c62ec" />

<img width="1526" height="889" alt="image" src="https://github.com/user-attachments/assets/4fde4be4-6348-45bc-9708-b92dd48eebcb" />



### Безопасность: что поменять в продакшене

Текущие правила безопасности Firestore разрешают чтение и запись всем пользователям без аутентификации. Это недопустимо для продакшен-среды.


### Ключевые файлы проекта

- **lib/main.dart** - точка входа приложения, инициализация Firebase
- **lib/firebase_options.dart** - конфигурация Firebase (автогенерация)
- **lib/notes_page.dart** - основной экран с CRUD-операциями
- **android/app/google-services.json** - конфигурация Firebase для Android
- **ios/Runner/GoogleService-Info.plist** - конфигурация Firebase для iOS

### Заключение

В ходе практического занятия успешно разработано Flutter-приложение, интегрированное с Firebase Firestore. Реализованы CRUD-операции и синхронизация данных в реальном времени.

# Relationship App

A Flutter application for generating meaningful relationship questions across different languages.

## Features

- Generate personalized relationship questions
- Multiple language support (English, Spanish, French)
- Conversation profiles with customizable settings
- Feedback system for question improvement

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Generate localization files:
   ```
   flutter gen-l10n
   ```
5. Run the app:
   ```
   flutter run
   ```

## Internationalization

This app supports multiple languages using Flutter's built-in internationalization.

### Adding New Languages

1. Create a new ARB file in `lib/l10n/` following the naming pattern `app_<language_code>.arb`
2. Copy the strings from `app_en.arb` and translate them to the new language
3. Run `flutter gen-l10n` to generate the localization files
4. Add the new locale to the `supportedLocales` list in `lib/providers/language_provider.dart`

### Regenerating Localization Files

If you make changes to any ARB files, run:

```
flutter gen-l10n
```

This will generate the required localization classes automatically from the ARB files.

## Project Structure

- `/lib/database`: Database helpers and schemas
- `/lib/l10n`: Localization files
- `/lib/models`: Data models
- `/lib/providers`: State management
- `/lib/services`: API and service classes
- `/lib/views`: UI screens
- `/lib/widgets`: Reusable UI components

## License

This project is proprietary software.
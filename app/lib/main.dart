import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/generated/app_localizations.dart';
import 'package:app/views/questions_view.dart';
import 'package:app/views/settings_view.dart';
import 'package:app/views/profiles_view.dart';
import 'package:app/providers/question_provider.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite_ffi
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  // Load the .env file
  await dotenv.load(fileName: '.env');

  // Create and initialize providers before the app starts
  final languageProvider = LanguageProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProxyProvider<ProfileProvider, QuestionProvider>(
          create: (context) => QuestionProvider(),
          update: (context, profileProvider, questionProvider) {
            if (profileProvider.activeProfile != null && questionProvider != null) {
              questionProvider.setActiveProfile(profileProvider.activeProfile!);
            }
            return questionProvider!;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Track locale to rebuild app when it changes
  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    // Get initial locale
    _currentLocale = Provider.of<LanguageProvider>(context, listen: false).currentLocale;

    // Set initial default question with the current language
    // Using WidgetsBinding to ensure we're not in the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
        questionProvider.updateDefaultQuestion(_currentLocale.languageCode);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if locale has changed
    final newLocale = Provider.of<LanguageProvider>(context).currentLocale;
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;

      // Use Future.microtask to update the default question after the current build completes
      Future.microtask(() {
        // This ensures the app responds to system language changes too
        Provider.of<QuestionProvider>(context, listen: false).updateDefaultQuestion(newLocale.languageCode);
      });

      // Force rebuild by calling setState
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to language changes
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      // key forces rebuild when locale changes
      key: ValueKey(languageProvider.currentLocale.languageCode),
      title: 'Relationship App',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, brightness: Brightness.light),

      // Localization setup - using Flutter generated localizations
      locale: languageProvider.currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // This ensures that the entire MaterialApp rebuilds when locale changes
      // This is an important part of making the official localization approach work
      localeResolutionCallback: (locale, supportedLocales) {
        return languageProvider.currentLocale;
      },

      initialRoute: '/',
      routes: {
        '/': (context) => const QuestionsView(),
        '/settings': (context) => const SettingsView(),
        '/profiles': (context) => const ProfilesView(),
      },
    );
  }
}

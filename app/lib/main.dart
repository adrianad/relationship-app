import 'package:flutter/material.dart';
import 'package:app/views/questions_view.dart';
import 'package:app/views/settings_view.dart';
import 'package:app/views/profiles_view.dart';
import 'package:app/providers/question_provider.dart';
import 'package:app/providers/profile_provider.dart';
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
  
  runApp(
    MultiProvider(
      providers: [
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relationship App',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const QuestionsView(),
        '/settings': (context) => const SettingsView(),
        '/profiles': (context) => const ProfilesView(),
      },
    );
  }
}
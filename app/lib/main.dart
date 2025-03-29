import 'package:flutter/material.dart';
import 'package:app/views/questions_view.dart';
import 'package:app/views/settings_view.dart';
import 'package:app/providers/question_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load the .env file
  await dotenv.load(fileName: '.env');
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => QuestionProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The MaterialApp is now a child of the Provider, so both routes can access it
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
      },
    );
  }
}
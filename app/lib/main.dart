import 'package:flutter/material.dart';
import 'package:app/views/questions_view.dart';
import 'package:app/views/settings_view.dart';

void main() {
  runApp(const MyApp());
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
      home: const QuestionsView(),
      routes: {
        '/settings': (context) => const SettingsView(),
      },
    );
  }
}
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/llm_service.dart';
import 'package:app/providers/question_provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Keys for shared preferences
  static const String _enabledKey = 'daily_notification_enabled';
  static const String _timeKey = 'daily_notification_time';

  // Default notification time (10:00 AM)
  static const TimeOfDay _defaultTime = TimeOfDay(hour: 10, minute: 0);

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Check if notifications are enabled and schedule if needed
    final prefs = await SharedPreferences.getInstance();
    final bool enabled = prefs.getBool(_enabledKey) ?? false;

    if (enabled) {
      await scheduleDaily();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to the app
    // This will be handled by the app's navigation system
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timeString = prefs.getString(_timeKey);

    if (timeString == null) {
      return _defaultTime;
    }

    try {
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return _defaultTime;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (enabled) {
      await scheduleDaily();
    } else {
      await cancelAll();
    }
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeKey, '${time.hour}:${time.minute}');

    // If notifications are enabled, reschedule with the new time
    final bool enabled = await isEnabled();
    if (enabled) {
      await scheduleDaily();
    }
  }

  Future<void> scheduleDaily() async {
    // Cancel any existing notifications
    await cancelAll();

    // Get the notification time
    final TimeOfDay time = await getNotificationTime();

    // Create a DateTime for the next occurrence of the notification time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);

    // If the scheduled time is in the past, schedule for the next day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Generate a random question for the notification
    final String question = await _generateRandomQuestion();

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID
      'Question of the Day', // Title
      question, // Body
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_question_channel',
          'Daily Question',
          channelDescription: 'Daily relationship question notifications',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.deepPurple,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the same time
    );
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<String> _generateRandomQuestion() async {
    try {
      // Create a temporary LLM service
      final llmService = LLMService();

      // Generate a random question with random parameters
      final Random random = Random();

      // Get random parameters from the available options
      final QuestionProvider questionProvider = QuestionProvider();

      final String depthOfRelationship =
          questionProvider.depthOptions[random.nextInt(questionProvider.depthOptions.length)];
      final String moodTone = questionProvider.moodOptions[random.nextInt(questionProvider.moodOptions.length)];
      final String context = questionProvider.contextOptions[random.nextInt(questionProvider.contextOptions.length)];
      final String comfortLevel =
          questionProvider.comfortOptions[random.nextInt(questionProvider.comfortOptions.length)];
      final String goalOfInteraction =
          questionProvider.goalOptions[random.nextInt(questionProvider.goalOptions.length)];
      final String thematicCategory =
          questionProvider.categoryOptions[random.nextInt(questionProvider.categoryOptions.length)];

      // Generate the question
      final question = await llmService.generateRelationshipQuestion(
        depthOfRelationship: depthOfRelationship,
        moodTone: moodTone,
        context: context,
        comfortLevel: comfortLevel,
        goalOfInteraction: goalOfInteraction,
        thematicCategory: thematicCategory,
      );

      return question;
    } catch (e) {
      // If there's an error, return a default question
      return "What's something you're looking forward to this week?";
    }
  }
}

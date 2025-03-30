import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app/models/profile.dart';
import 'package:app/models/question_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('questions_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB
    );
  }
  
  // Handles database migrations
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the new columns to the profiles table for random settings
      await db.execute('ALTER TABLE profiles ADD COLUMN any_mood_tone INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE profiles ADD COLUMN any_category INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE profiles ADD COLUMN any_goal INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE profiles ADD COLUMN last_random_mood_tone TEXT');
      await db.execute('ALTER TABLE profiles ADD COLUMN last_random_category TEXT');
      await db.execute('ALTER TABLE profiles ADD COLUMN last_random_goal TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Create profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        is_active INTEGER NOT NULL,
        depth_of_relationship TEXT NOT NULL,
        mood_tone TEXT NOT NULL,
        context TEXT NOT NULL,
        comfort_level TEXT NOT NULL,
        goal_of_interaction TEXT NOT NULL,
        thematic_category TEXT NOT NULL,
        llm_provider TEXT NOT NULL,
        any_mood_tone INTEGER NOT NULL DEFAULT 0,
        any_category INTEGER NOT NULL DEFAULT 0,
        any_goal INTEGER NOT NULL DEFAULT 0,
        last_random_mood_tone TEXT,
        last_random_category TEXT,
        last_random_goal TEXT
      )
    ''');

    // Create questions table
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        rating INTEGER NOT NULL,
        more_like_this INTEGER NOT NULL,
        less_like_this INTEGER NOT NULL,
        relevance TEXT,
        comfort_level TEXT,
        enjoyment TEXT,
        depth_appropriateness TEXT,
        intimacy_appropriateness TEXT,
        depth_of_relationship TEXT NOT NULL,
        mood_tone TEXT NOT NULL,
        context TEXT NOT NULL,
        comfort_level_setting TEXT NOT NULL,
        goal_of_interaction TEXT NOT NULL,
        thematic_category TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
      )
    ''');

    // Create index on profile_id for faster lookups
    await db.execute('CREATE INDEX idx_questions_profile_id ON questions (profile_id)');

    // Create unique index on question text to prevent duplicates
    await db.execute('CREATE UNIQUE INDEX idx_questions_unique ON questions (profile_id, question)');

    // Insert default profile
    final defaultProfile = Profile.defaultProfile();
    await db.insert('profiles', defaultProfile.toMap());
  }

  // Profile CRUD operations
  Future<int> insertProfile(Profile profile) async {
    final db = await database;
    return await db.insert('profiles', profile.toMap());
  }

  Future<List<Profile>> getAllProfiles() async {
    final db = await database;
    final result = await db.query('profiles');
    return result.map((map) => Profile.fromMap(map)).toList();
  }

  Future<Profile?> getProfile(int id) async {
    final db = await database;
    final maps = await db.query('profiles', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<Profile?> getActiveProfile() async {
    final db = await database;
    final maps = await db.query('profiles', where: 'is_active = ?', whereArgs: [1]);

    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    return await db.update('profiles', profile.toMap(), where: 'id = ?', whereArgs: [profile.id]);
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setActiveProfile(int id) async {
    final db = await database;

    // Begin transaction
    await db.transaction((txn) async {
      // First, set all profiles to inactive
      await txn.update('profiles', {'is_active': 0});

      // Then set the selected profile to active
      await txn.update('profiles', {'is_active': 1}, where: 'id = ?', whereArgs: [id]);
    });
  }

  // Question CRUD operations
  Future<int> insertQuestion(QuestionRecord question) async {
    final db = await database;
    try {
      return await db.insert('questions', question.toMap());
    } on DatabaseException catch (e) {
      // Handle unique constraint error
      if (e.isUniqueConstraintError()) {
        // Get the existing question
        final existingQuestion = await getQuestionByText(question.profileId, question.question);
        if (existingQuestion != null) {
          // Update the existing question with new feedback data
          return await updateQuestion(
            existingQuestion.copyWith(
              rating: question.rating,
              moreLikeThis: question.moreLikeThis,
              lessLikeThis: question.lessLikeThis,
              relevance: question.relevance,
              comfortLevel: question.comfortLevel,
              enjoyment: question.enjoyment,
              depthAppropriateness: question.depthAppropriateness,
              intimacyAppropriateness: question.intimacyAppropriateness,
            ),
          );
        }
      }
      rethrow;
    }
  }

  Future<QuestionRecord?> getQuestionByText(int profileId, String questionText) async {
    final db = await database;
    final maps = await db.query(
      'questions',
      where: 'profile_id = ? AND question = ?',
      whereArgs: [profileId, questionText],
    );

    if (maps.isNotEmpty) {
      return QuestionRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<List<QuestionRecord>> getQuestionsForProfile(int profileId, {int limit = 50}) async {
    final db = await database;
    final result = await db.query(
      'questions',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => QuestionRecord.fromMap(map)).toList();
  }

  Future<int> updateQuestion(QuestionRecord question) async {
    final db = await database;
    return await db.update('questions', question.toMap(), where: 'id = ?', whereArgs: [question.id]);
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete('questions', where: 'id = ?', whereArgs: [id]);
  }

  // Formatting history for prompts - optimized version
  Future<String> getFormattedHistory(int profileId, {int maxRecords = 10}) async {
    final allQuestions = await getQuestionsForProfile(profileId, limit: maxRecords * 3);

    if (allQuestions.isEmpty) {
      return '';
    }

    // Sort questions by rating to prioritize high-rated and low-rated for better learning
    final sortedQuestions = [...allQuestions];
    sortedQuestions.sort((a, b) {
      // First prioritize questions with like/dislike feedback
      final aHasFeedback = a.moreLikeThis || a.lessLikeThis;
      final bHasFeedback = b.moreLikeThis || b.lessLikeThis;
      
      if (aHasFeedback && !bHasFeedback) return -1;
      if (!aHasFeedback && bHasFeedback) return 1;
      
      // Then sort by rating (highest first, then lowest)
      if (a.rating >= 4 && b.rating < 4) return -1;
      if (a.rating < 4 && b.rating >= 4) return 1;
      if (a.rating <= 1 && b.rating > 1) return -1; 
      if (a.rating > 1 && b.rating <= 1) return 1;
      
      // Then sort by recency
      return b.timestamp.compareTo(a.timestamp);
    });
    
    // Take the most relevant questions for the model, limited by maxRecords
    final questions = sortedQuestions.take(maxRecords).toList();

    // Build the formatted history string with a helpful introduction
    String historyText = '''

QUESTION HISTORY (learn from this feedback):
**Avoid repeating previously asked questions** listed below.
Focus on characteristics of highly-rated questions and avoid characteristics of poorly-rated ones.

''';

    for (int i = 0; i < questions.length; i++) {
      historyText += questions[i].toPromptEntry(i + 1);

      // Add spacing between entries
      if (i < questions.length - 1) {
        historyText += '\n';
      }
    }

    return historyText;
  }

  // Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

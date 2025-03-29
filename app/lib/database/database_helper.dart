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
      version: 1,
      onCreate: _createDB,
    );
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
        llm_provider TEXT NOT NULL
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
    final maps = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<Profile?> getActiveProfile() async {
    final db = await database;
    final maps = await db.query(
      'profiles',
      where: 'is_active = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return Profile.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    return await db.update(
      'profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> setActiveProfile(int id) async {
    final db = await database;
    
    // Begin transaction
    await db.transaction((txn) async {
      // First, set all profiles to inactive
      await txn.update(
        'profiles',
        {'is_active': 0},
      );
      
      // Then set the selected profile to active
      await txn.update(
        'profiles',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
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
    return await db.update(
      'questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  Future<int> deleteQuestion(int id) async {
    final db = await database;
    return await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Formatting history for prompts
  Future<String> getFormattedHistory(int profileId, {int maxRecords = 5}) async {
    final questions = await getQuestionsForProfile(profileId, limit: maxRecords);
    
    if (questions.isEmpty) {
      return '';
    }
    
    // Build the formatted history string
    String historyText = '\n**Avoid repeating previously asked questions** listed below (with provided feedback):\n\n';
    
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
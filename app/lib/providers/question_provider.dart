import 'package:flutter/material.dart';
import 'package:app/services/llm_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/models/question_record.dart';
import 'package:app/models/profile.dart';
import 'package:app/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionProvider extends ChangeNotifier {
  final LLMService _llmService = LLMService();
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  // Default questions for different languages
  final Map<String, String> _defaultQuestions = {
    'en': "How was your day today?",
    'es': "¿Cómo ha sido tu día hoy?",
    'fr': "Comment s'est passée ta journée aujourd'hui?",
    'de': "Wie war dein Tag heute?",
  };
  
  String _currentQuestion = "How was your day today?";
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentLanguage = 'en';
  
  // Temporary memory for random selections (not persisted to profile)
  String? _tempRandomMoodTone;
  String? _tempRandomCategory;
  String? _tempRandomGoal;
  
  // Active profile reference - will be set by the app
  Profile? _activeProfile;
  
  // Options for dropdowns and multi-selects
  final List<String> depthOptions = ['Acquaintances', 'Friends', 'Close Friends', 'Partners/Lovers'];
  final List<String> moodOptions = ['Neutral/Balanced', 'Funny/Playful', 'Serious/Thoughtful', 'Deep/Reflective', 'Sensual/Intimate', 'Crazy/Absurd', 'Provocative/Dirty'];
  final List<String> contextOptions = ['Casual hangout', 'Date night', 'Online chat', 'Party setting', 'Private/intimate setting', 'Road trip', 'Dinner conversation'];
  final List<String> comfortOptions = ['Safe (low risk)', 'Moderate', 'High Risk'];
  final List<String> goalOptions = ['Getting to know each other better', 'Deepening intimacy', 'Breaking the ice', 'Stimulating thoughtful discussion', 'Provoking humor/playfulness', 'Exploring fantasies/desires'];
  final List<String> categoryOptions = ['Past experiences', 'Personal values/beliefs', 'Hypothetical scenarios', 'Dreams/goals/ambitions', 'Preferences', 'Relationships/intimacy', 'Secrets/confessions'];
  
  // Constructor - initialize with current language
  QuestionProvider() {
    _initializeLanguage();
  }
  
  // Initialize the provider with the system language or saved language
  Future<void> _initializeLanguage() async {
    try {
      // Initialize with default question in current language
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('app_language');
      
      if (savedLanguage != null) {
        _currentLanguage = savedLanguage;
        _currentQuestion = _defaultQuestions[savedLanguage] ?? _defaultQuestions['en']!;
      }
    } catch (e) {
      print('Error initializing language: $e');
    }
  }
  
  // Getters
  String get currentQuestion => _currentQuestion;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get currentLanguage => _currentLanguage;
  
  // Getters for last randomly selected options from the active profile or temporary memory
  String? get lastRandomMoodTone => _tempRandomMoodTone ?? _activeProfile?.lastRandomMoodTone;
  String? get lastRandomCategory => _tempRandomCategory ?? _activeProfile?.lastRandomCategory;
  String? get lastRandomGoal => _tempRandomGoal ?? _activeProfile?.lastRandomGoal;
  
  // Getters for random selection settings
  bool get anyMoodTone => _activeProfile?.anyMoodTone ?? false;
  bool get anyCategory => _activeProfile?.anyCategory ?? false;
  bool get anyGoal => _activeProfile?.anyGoal ?? false;
  
  // Get default question for a specific language
  String getDefaultQuestion(String languageCode) {
    return _defaultQuestions[languageCode] ?? _defaultQuestions['en']!;
  }
  
  // Forward profile getters
  String get depthOfRelationship => _activeProfile?.depthOfRelationship ?? 'Friends';
  List<String> get moodTone => _activeProfile?.moodTone ?? ['Funny/Playful'];
  String get context => _activeProfile?.context ?? 'Casual hangout';
  String get comfortLevel => _activeProfile?.comfortLevel ?? 'Moderate';
  List<String> get goalOfInteraction => _activeProfile?.goalOfInteraction ?? ['Getting to know each other better'];
  List<String> get thematicCategory => _activeProfile?.thematicCategory ?? ['Past experiences'];
  String get currentProvider => _activeProfile?.llmProvider ?? 'OpenAI';
  
  // Set active profile
  void setActiveProfile(Profile profile) {
    _activeProfile = profile;
    notifyListeners();
  }
  
  // Update the default question when language changes
  Future<void> updateDefaultQuestion(String languageCode) async {
    // Check if language is actually changing
    if (_currentLanguage == languageCode && 
        _currentQuestion == (_defaultQuestions[languageCode] ?? _defaultQuestions['en']!)) {
      return; // No change needed
    }
    
    // Update the language and question
    _currentLanguage = languageCode;
    _currentQuestion = _defaultQuestions[languageCode] ?? _defaultQuestions['en']!;
    
    // Notify listeners
    notifyListeners();
  }
  
  // Add a new language with its default question
  void addLanguageDefaultQuestion(String languageCode, String defaultQuestion) {
    _defaultQuestions[languageCode] = defaultQuestion;
  }
  
  // Initialize the LLM service with the selected provider
  Future<void> _initializeService() async {
    try {
      if (_activeProfile == null) {
        // Get active profile from database if not set
        _activeProfile = await _db.getActiveProfile();
        if (_activeProfile == null) {
          throw Exception('No active profile found');
        }
      }
      
      switch (_activeProfile!.llmProvider) {
        case 'OpenAI':
          _llmService.setProvider(LLMProviderFactory.createOpenAIProvider());
          break;
        case 'Anthropic':
          _llmService.setProvider(LLMProviderFactory.createAnthropicProvider());
          break;
        case 'Gemini':
          _llmService.setProvider(LLMProviderFactory.createGeminiProvider());
          break;
        default:
          _errorMessage = 'Please select a provider in settings';
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize LLM service: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Change the LLM provider for the active profile
  Future<void> setProvider(String providerName) async {
    try {
      if (_activeProfile == null) {
        throw Exception('No active profile');
      }
      
      final updatedProfile = _activeProfile!.copyWith(llmProvider: providerName);
      await _db.updateProfile(updatedProfile);
      _activeProfile = updatedProfile;
      
      switch (providerName) {
        case 'OpenAI':
          _llmService.setProvider(LLMProviderFactory.createOpenAIProvider());
          break;
        case 'Anthropic':
          _llmService.setProvider(LLMProviderFactory.createAnthropicProvider());
          break;
        case 'Gemini':
          _llmService.setProvider(LLMProviderFactory.createGeminiProvider());
          break;
        default:
          throw Exception('Unknown provider: $providerName');
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to set provider: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Update settings for the active profile
  Future<void> updateSettings({
    String? depthOfRelationship,
    List<String>? moodTone,
    String? context,
    String? comfortLevel,
    List<String>? goalOfInteraction,
    List<String>? thematicCategory,
    bool? anyMoodTone,
    bool? anyCategory,
    bool? anyGoal,
    String? lastRandomMoodTone,
    String? lastRandomCategory,
    String? lastRandomGoal,
  }) async {
    try {
      if (_activeProfile == null) {
        throw Exception('No active profile');
      }
      
      final updatedProfile = _activeProfile!.copyWith(
        depthOfRelationship: depthOfRelationship,
        moodTone: moodTone,
        context: context,
        comfortLevel: comfortLevel,
        goalOfInteraction: goalOfInteraction,
        thematicCategory: thematicCategory,
        anyMoodTone: anyMoodTone,
        anyCategory: anyCategory,
        anyGoal: anyGoal,
        lastRandomMoodTone: lastRandomMoodTone,
        lastRandomCategory: lastRandomCategory,
        lastRandomGoal: lastRandomGoal,
      );
      
      await _db.updateProfile(updatedProfile);
      _activeProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update settings: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Generate a new question
  Future<void> generateQuestion({
    String? language,
    String? presetMoodTone,
    String? presetCategory,
    String? presetComfortLevel,
    String? presetGoal,
    String? presetDepth,
    bool keepCurrentSettings = false,
    bool anyMoodTone = false,
    bool anyCategory = false,
    bool anyGoal = false,
    bool temporaryRandom = false // Flag to indicate if random is just temporary
  }) async {
    _isLoading = true;
    _errorMessage = '';
    
    // Use provided language code or current language
    final languageCode = language ?? _currentLanguage;
    // Update current language if provided
    if (language != null) {
      _currentLanguage = language;
    }
    
    notifyListeners();
    
    try {
      // Ensure we have an active profile
      if (_activeProfile == null) {
        _activeProfile = await _db.getActiveProfile();
        if (_activeProfile == null) {
          throw Exception('No active profile found');
        }
      }
      
      // Initialize the service if needed
      await _initializeService();
      
      // Get formatted question history for the prompt
      final questionHistory = await _db.getFormattedHistory(_activeProfile!.id!);
      
      // Use preset values or current profile settings
      String depthToUse = presetDepth ?? _activeProfile!.depthOfRelationship;
      List<String> moodToneToUse = List.from(_activeProfile!.moodTone);
      String contextToUse = _activeProfile!.context;
      String comfortLevelToUse = presetComfortLevel ?? _activeProfile!.comfortLevel;
      List<String> goalToUse = List.from(_activeProfile!.goalOfInteraction);
      List<String> categoryToUse = List.from(_activeProfile!.thematicCategory);
      
      // Only override settings if not keeping current settings and not using "anything" options
      if (!keepCurrentSettings) {
        if (presetMoodTone != null && !anyMoodTone) {
          moodToneToUse = [presetMoodTone];
        }
        
        if (presetCategory != null && !anyCategory) {
          categoryToUse = [presetCategory];
        }
        
        if (presetGoal != null && !anyGoal) {
          goalToUse = [presetGoal];
        }
      }
      
      // Prepare the strings for the prompt
      String moodToneStr;
      String goalStr;
      String categoryStr;
      
      // Handle "Random" options - pick a random option for each
      String? newRandomMoodTone;
      String? newRandomCategory;
      String? newRandomGoal;
      
      if (anyMoodTone || moodToneToUse.contains('Random')) {
        // Choose a random mood tone from options
        final randomMood = moodOptions[DateTime.now().microsecond % moodOptions.length];
        moodToneStr = randomMood;
        newRandomMoodTone = randomMood; // Store the randomly selected mood
      } else {
        moodToneStr = moodToneToUse.join(' | ');
        newRandomMoodTone = null; // Clear the random selection when not using random
      }
      
      if (anyCategory || categoryToUse.contains('Random')) {
        // Choose a random category from options
        final randomCategory = categoryOptions[DateTime.now().millisecond % categoryOptions.length];
        categoryStr = randomCategory;
        newRandomCategory = randomCategory; // Store the randomly selected category
      } else {
        categoryStr = categoryToUse.join(' | ');
        newRandomCategory = null; // Clear the random selection when not using random
      }
      
      if (anyGoal || goalToUse.contains('Random')) {
        // Choose a random goal from options
        final randomGoal = goalOptions[DateTime.now().second % goalOptions.length];
        goalStr = randomGoal;
        newRandomGoal = randomGoal; // Store the randomly selected goal
      } else {
        goalStr = goalToUse.join(' | ');
        newRandomGoal = null; // Clear the random selection when not using random
      }
      
      // Update the profile with the new random selections if not temporary
      if (_activeProfile != null && !temporaryRandom) {
        // Only update if the values actually changed
        if (newRandomMoodTone != _activeProfile!.lastRandomMoodTone || 
            newRandomCategory != _activeProfile!.lastRandomCategory || 
            newRandomGoal != _activeProfile!.lastRandomGoal) {
          await updateSettings(
            lastRandomMoodTone: newRandomMoodTone,
            lastRandomCategory: newRandomCategory,
            lastRandomGoal: newRandomGoal
          );
        }
        
        // Only update the any* flags if they've changed and we're not in temporary mode
        if (anyMoodTone != _activeProfile!.anyMoodTone ||
            anyCategory != _activeProfile!.anyCategory ||
            anyGoal != _activeProfile!.anyGoal) {
          await updateSettings(
            anyMoodTone: anyMoodTone,
            anyCategory: anyCategory,
            anyGoal: anyGoal
          );
        }
      } else {
        // For temporary random, we still need the current random selections in memory
        _tempRandomMoodTone = newRandomMoodTone;
        _tempRandomCategory = newRandomCategory;
        _tempRandomGoal = newRandomGoal;
      }
      
      final question = await _llmService.generateRelationshipQuestion(
        depthOfRelationship: depthToUse,
        moodTone: moodToneStr,
        context: contextToUse,
        comfortLevel: comfortLevelToUse,
        goalOfInteraction: goalStr,
        thematicCategory: categoryStr,
        questionHistory: questionHistory,
        language: languageCode,
      );
      
      _currentQuestion = question;
      
      // Clear temporary random values if this wasn't a temporary random question
      if (!temporaryRandom) {
        _tempRandomMoodTone = null;
        _tempRandomCategory = null;
        _tempRandomGoal = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to generate question: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Convenience presets for quick question generation
  Future<void> generateFunnyQuestion({String? language}) async {
    // Don't update settings, just generate a question with these parameters
    return generateQuestion(
      language: language,
      presetMoodTone: 'Funny/Playful',
      presetCategory: 'Hypothetical scenarios',
      presetGoal: 'Provoking humor/playfulness',
      // Don't modify context or comfort level
      keepCurrentSettings: false
    );
  }
  
  Future<void> generateDeepQuestion({String? language}) async {
    // Don't update settings, just generate a question with these parameters
    return generateQuestion(
      language: language,
      presetMoodTone: 'Deep/Reflective',
      presetCategory: 'Personal values/beliefs',
      presetGoal: 'Stimulating thoughtful discussion',
      // Don't modify context or comfort level
      keepCurrentSettings: false
    );
  }
  
  Future<void> generateIcebreakerQuestion({String? language}) async {
    // Don't update settings, just generate a question with these parameters
    return generateQuestion(
      language: language,
      presetMoodTone: 'Funny/Playful',
      presetCategory: 'Preferences',
      presetGoal: 'Breaking the ice',
      // Don't modify context or comfort level
      keepCurrentSettings: false
    );
  }
  
  Future<void> regenerateWithSameSettings({String? language}) async {
    return generateQuestion(
      language: language,
      keepCurrentSettings: true
    );
  }
  
  Future<void> generateRandomQuestion({String? language}) async {
    // Generate question with random parameters but don't update saved settings
    // We'll temporarily set all parameters to 'Random'
    
    // Save current settings
    List<String> originalMoodTone = List.from(_activeProfile?.moodTone ?? []);
    List<String> originalCategory = List.from(_activeProfile?.thematicCategory ?? []);
    List<String> originalGoal = List.from(_activeProfile?.goalOfInteraction ?? []);
    
    try {
      // Generate with temporary 'Random' settings
      return await generateQuestion(
        language: language,
        presetMoodTone: 'Random',
        presetCategory: 'Random',
        presetGoal: 'Random',
        temporaryRandom: true  // Flag to indicate this is a temporary random selection
      );
    } finally {
      // Restore the original settings (don't wait for the result since we don't need it)
      if (_activeProfile != null) {
        updateSettings(
          moodTone: originalMoodTone,
          thematicCategory: originalCategory,
          goalOfInteraction: originalGoal
        );
      }
    }
  }
  
  // Save question with feedback to database
  Future<void> saveQuestionToHistory({
    required int rating,
    required bool moreLikeThis,
    required bool lessLikeThis,
  }) async {
    try {
      if (_activeProfile == null) {
        throw Exception('No active profile found');
      }
      
      // Prepare the record
      final record = QuestionRecord(
        profileId: _activeProfile!.id!,
        question: _currentQuestion,
        rating: rating,
        moreLikeThis: moreLikeThis,
        lessLikeThis: lessLikeThis,
        // Settings used to generate this question
        depthOfRelationship: _activeProfile!.depthOfRelationship,
        moodTone: _activeProfile!.moodTone.join(', '),
        context: _activeProfile!.context,
        comfortLevelSetting: _activeProfile!.comfortLevel,
        goalOfInteraction: _activeProfile!.goalOfInteraction.join(', '),
        thematicCategory: _activeProfile!.thematicCategory.join(', '),
      );
      
      await _db.insertQuestion(record);
    } catch (e) {
      print('Error saving question to history: $e');
    }
  }
}
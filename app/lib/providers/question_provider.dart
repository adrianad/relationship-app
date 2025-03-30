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
  
  // Active profile reference - will be set by the app
  Profile? _activeProfile;
  
  // Options for dropdowns and multi-selects
  final List<String> depthOptions = ['Acquaintances', 'Friends', 'Close Friends', 'Partners/Lovers'];
  final List<String> moodOptions = ['Funny/Playful', 'Serious/Thoughtful', 'Deep/Reflective', 'Sensual/Intimate', 'Crazy/Absurd', 'Provocative/Dirty'];
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
    bool keepCurrentSettings = false,
    bool anyMoodTone = false,
    bool anyCategory = false,
    bool anyGoal = false
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
      String depthToUse = _activeProfile!.depthOfRelationship;
      List<String> moodToneToUse = List.from(_activeProfile!.moodTone);
      String contextToUse = _activeProfile!.context;
      String comfortLevelToUse = presetComfortLevel ?? _activeProfile!.comfortLevel;
      List<String> goalToUse = List.from(_activeProfile!.goalOfInteraction);
      List<String> categoryToUse = List.from(_activeProfile!.thematicCategory);
      
      // Override settings with presets if provided and not keeping current settings
      if (!keepCurrentSettings) {
        if (presetMoodTone != null) {
          moodToneToUse = [presetMoodTone];
        }
        
        if (presetCategory != null) {
          categoryToUse = [presetCategory];
        }
        
        if (presetGoal != null) {
          goalToUse = [presetGoal];
        }
      }
      
      // Prepare the strings for the prompt
      String moodToneStr;
      String goalStr;
      String categoryStr;
      
      // Handle "Anything" options
      if (anyMoodTone) {
        moodToneStr = "Any mood/tone at your discretion";
      } else {
        moodToneStr = moodToneToUse.join(' | ');
      }
      
      if (anyCategory) {
        categoryStr = "Any thematic category at your discretion";
      } else {
        categoryStr = categoryToUse.join(' | ');
      }
      
      if (anyGoal) {
        goalStr = "Any goal of interaction at your discretion";
      } else {
        goalStr = goalToUse.join(' | ');
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
    return generateQuestion(
      language: language,
      presetMoodTone: 'Funny/Playful',
      presetCategory: 'Hypothetical scenarios'
    );
  }
  
  Future<void> generateDeepQuestion({String? language}) async {
    return generateQuestion(
      language: language,
      presetMoodTone: 'Deep/Reflective',
      presetCategory: 'Personal values/beliefs',
      presetComfortLevel: 'Moderate'
    );
  }
  
  Future<void> generateIcebreakerQuestion({String? language}) async {
    return generateQuestion(
      language: language,
      presetMoodTone: 'Funny/Playful',
      presetCategory: 'Preferences',
      presetComfortLevel: 'Safe (low risk)'
    );
  }
  
  Future<void> regenerateWithSameSettings({String? language}) async {
    return generateQuestion(
      language: language,
      keepCurrentSettings: true
    );
  }
  
  Future<void> generateRandomQuestion({String? language}) async {
    // Generate random settings
    final random = DateTime.now().millisecondsSinceEpoch;
    
    // Pick a random depth
    final randomDepth = depthOptions[random % depthOptions.length];
    
    // Pick a random context
    final randomContext = contextOptions[(random ~/ 3) % contextOptions.length];
    
    // Pick a random comfort level
    final randomComfort = comfortOptions[(random ~/ 5) % comfortOptions.length];
    
    // Update settings with random values
    await updateSettings(
      depthOfRelationship: randomDepth,
      context: randomContext,
      comfortLevel: randomComfort,
    );
    
    // Generate question with the random settings
    return generateQuestion(
      language: language,
      anyMoodTone: true,
      anyCategory: true,
      anyGoal: true,
      keepCurrentSettings: true
    );
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
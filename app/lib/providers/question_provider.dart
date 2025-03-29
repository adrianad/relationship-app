import 'package:flutter/material.dart';
import 'package:app/services/llm_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/models/question_history.dart';

class QuestionProvider extends ChangeNotifier {
  final LLMService _llmService = LLMService();
  
  String _currentQuestion = "How was your day today?";
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Settings - New format
  String _depthOfRelationship = 'Friends';
  List<String> _moodTone = ['Funny/Playful'];
  String _context = 'Casual hangout';
  String _comfortLevel = 'Moderate';
  List<String> _goalOfInteraction = ['Getting to know each other better'];
  List<String> _thematicCategory = ['Past experiences'];
  String _currentProvider = 'OpenAI';
  
  // Options for dropdowns and multi-selects
  final List<String> depthOptions = ['Acquaintances', 'Friends', 'Close Friends', 'Partners/Lovers'];
  final List<String> moodOptions = ['Funny/Playful', 'Serious/Thoughtful', 'Deep/Reflective', 'Sensual/Intimate', 'Crazy/Absurd', 'Provocative/Dirty'];
  final List<String> contextOptions = ['Casual hangout', 'Date night', 'Online chat', 'Party setting', 'Private/intimate setting', 'Road trip', 'Dinner conversation'];
  final List<String> comfortOptions = ['Safe (low risk)', 'Moderate', 'High Risk'];
  final List<String> goalOptions = ['Getting to know each other better', 'Deepening intimacy', 'Breaking the ice', 'Stimulating thoughtful discussion', 'Provoking humor/playfulness', 'Exploring fantasies/desires'];
  final List<String> categoryOptions = ['Past experiences', 'Personal values/beliefs', 'Hypothetical scenarios', 'Dreams/goals/ambitions', 'Preferences', 'Relationships/intimacy', 'Secrets/confessions'];
  
  // Getters
  String get currentQuestion => _currentQuestion;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get depthOfRelationship => _depthOfRelationship;
  List<String> get moodTone => _moodTone;
  String get context => _context;
  String get comfortLevel => _comfortLevel;
  List<String> get goalOfInteraction => _goalOfInteraction;
  List<String> get thematicCategory => _thematicCategory;
  String get currentProvider => _currentProvider;
  
  // Initialize the provider with default settings
  QuestionProvider() {
    // Initialize with a safe default - no API calls until explicitly requested
    _currentProvider = 'OpenAI';
  }
  
  // Initialize the LLM service with the selected provider
  Future<void> _initializeService() async {
    try {
      switch (_currentProvider) {
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
          // Default to a placeholder provider if none available
          _errorMessage = 'Please select a provider in settings';
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize LLM service: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Change the LLM provider
  Future<void> setProvider(String providerName) async {
    try {
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
      _currentProvider = providerName;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to set provider: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Update settings
  void updateSettings({
    String? depthOfRelationship,
    List<String>? moodTone,
    String? context,
    String? comfortLevel,
    List<String>? goalOfInteraction,
    List<String>? thematicCategory,
  }) {
    if (depthOfRelationship != null) _depthOfRelationship = depthOfRelationship;
    if (moodTone != null) _moodTone = moodTone;
    if (context != null) _context = context;
    if (comfortLevel != null) _comfortLevel = comfortLevel;
    if (goalOfInteraction != null) _goalOfInteraction = goalOfInteraction;
    if (thematicCategory != null) _thematicCategory = thematicCategory;
    notifyListeners();
  }
  
  // Generate a new question
  Future<void> generateQuestion() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      // Initialize the service if needed
      await _initializeService();
      
      // Get formatted question history for the prompt
      final questionHistory = await QuestionHistory.getFormattedHistory();
      
      // Concatenate multi-select values for the prompt
      final moodToneStr = _moodTone.join(' | ');
      final goalStr = _goalOfInteraction.join(' | ');
      final categoryStr = _thematicCategory.join(' | ');
      
      final question = await _llmService.generateRelationshipQuestion(
        depthOfRelationship: _depthOfRelationship,
        moodTone: moodToneStr,
        context: _context,
        comfortLevel: _comfortLevel,
        goalOfInteraction: goalStr,
        thematicCategory: categoryStr,
        questionHistory: questionHistory,
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
  
  // Save question with feedback to history
  Future<void> saveQuestionToHistory({
    required int rating,
    required bool moreLikeThis,
    required bool lessLikeThis,
    String? relevance,
    String? comfortLevel,
    String? enjoyment,
    String? depthAppropriateness,
    String? intimacyAppropriateness,
  }) async {
    try {
      // For historical purposes, we'll keep the same format but set default values
      // since we've changed the parameters
      const int defaultParamValue = 5;
      
      final record = QuestionRecord(
        question: _currentQuestion,
        intimacyLevel: defaultParamValue,
        depthLevel: defaultParamValue,
        purposeLevel: defaultParamValue,
        rating: rating,
        moreLikeThis: moreLikeThis,
        lessLikeThis: lessLikeThis,
        relevance: relevance,
        comfortLevel: comfortLevel,
        enjoyment: enjoyment,
        depthAppropriateness: depthAppropriateness,
        intimacyAppropriateness: intimacyAppropriateness,
        // Add new parameters
        depthOfRelationship: _depthOfRelationship,
        moodTone: _moodTone.join(', '),
        context: _context,
        comfortLevelSetting: _comfortLevel,
        goalOfInteraction: _goalOfInteraction.join(', '),
        thematicCategory: _thematicCategory.join(', '),
      );
      
      await QuestionHistory.addRecord(record);
    } catch (e) {
      print('Error saving question to history: $e');
    }
  }
}
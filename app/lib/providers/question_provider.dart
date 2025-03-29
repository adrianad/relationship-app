import 'package:flutter/material.dart';
import 'package:app/services/llm_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/models/question_history.dart';

class QuestionProvider extends ChangeNotifier {
  final LLMService _llmService = LLMService();
  
  String _currentQuestion = "How was your day today?";
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Settings
  int _intimacyLevel = 5;
  int _depthLevel = 5;
  int _purposeLevel = 5;
  String _currentProvider = 'OpenAI';
  
  // Getters
  String get currentQuestion => _currentQuestion;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get intimacyLevel => _intimacyLevel;
  int get depthLevel => _depthLevel;
  int get purposeLevel => _purposeLevel;
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
  void updateSettings({int? intimacy, int? depth, int? purpose}) {
    if (intimacy != null) _intimacyLevel = intimacy;
    if (depth != null) _depthLevel = depth;
    if (purpose != null) _purposeLevel = purpose;
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
      
      final question = await _llmService.generateRelationshipQuestion(
        intimacyLevel: _intimacyLevel,
        depthLevel: _depthLevel,
        purposeLevel: _purposeLevel,
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
      final record = QuestionRecord(
        question: _currentQuestion,
        intimacyLevel: _intimacyLevel,
        depthLevel: _depthLevel,
        purposeLevel: _purposeLevel,
        rating: rating,
        moreLikeThis: moreLikeThis,
        lessLikeThis: lessLikeThis,
        relevance: relevance,
        comfortLevel: comfortLevel,
        enjoyment: enjoyment,
        depthAppropriateness: depthAppropriateness,
        intimacyAppropriateness: intimacyAppropriateness,
      );
      
      await QuestionHistory.addRecord(record);
    } catch (e) {
      print('Error saving question to history: $e');
    }
  }
}
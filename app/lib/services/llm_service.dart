import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Helper function to normalize text encoding issues
String normalizeText(String text) {
  // Replace common problematic characters
  return text
      .replaceAll(''', "'")
    .replaceAll(''', "'")
      .replaceAll('"', '"')
      .replaceAll('"', '"')
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('…', '...')
      .replaceAll('\u00A0', ' '); // Replace non-breaking space with regular space
}

/// Abstract LLM Provider class to enable easy provider swapping
abstract class LLMProvider {
  /// Makes an API request to generate text
  Future<String> generateText(String prompt);

  /// Returns a user-friendly name for the provider
  String get providerName;

  /// Returns the model identifier being used
  String get modelIdentifier;
}

/// Implementation for OpenAI API
class OpenAIProvider implements LLMProvider {
  final String _apiKey;
  final String _model;
  final String _endpoint;

  OpenAIProvider({
    required String apiKey,
    String model = 'gpt-4o-mini',
    String endpoint = 'https://api.openai.com/v1/chat/completions',
  }) : _apiKey = apiKey,
       _model = model,
       _endpoint = endpoint;

  @override
  Future<String> generateText(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {'Content-Type': 'application/json; charset=utf-8', 'Authorization': 'Bearer $_apiKey'},
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'].trim();
        // Normalize apostrophes and quotes to ensure they display correctly
        return normalizeText(content);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate text: $e');
    }
  }

  @override
  String get providerName => 'OpenAI';

  @override
  String get modelIdentifier => _model;
}

/// Implementation for Anthropic API
class AnthropicProvider implements LLMProvider {
  final String _apiKey;
  final String _model;
  final String _endpoint;

  AnthropicProvider({
    required String apiKey,
    String model = 'claude-3-haiku-20240307',
    String endpoint = 'https://api.anthropic.com/v1/messages',
  }) : _apiKey = apiKey,
       _model = model,
       _endpoint = endpoint;

  @override
  Future<String> generateText(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['content'][0]['text'].trim();
        // Normalize apostrophes and quotes to ensure they display correctly
        return normalizeText(content);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate text: $e');
    }
  }

  @override
  String get providerName => 'Anthropic';

  @override
  String get modelIdentifier => _model;
}

/// Implementation for Google Gemini API
class GeminiProvider implements LLMProvider {
  final String _apiKey;
  final String _model;
  final String _endpoint;

  GeminiProvider({
    required String apiKey,
    String model = 'gemini-pro',
    String endpoint = 'https://generativelanguage.googleapis.com/v1beta/models',
  }) : _apiKey = apiKey,
       _model = model,
       _endpoint = endpoint;

  @override
  Future<String> generateText(String prompt) async {
    try {
      // Construct the complete URL with model and API key
      final url = '$_endpoint/$_model:generateContent?key=$_apiKey';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 150},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['candidates'][0]['content']['parts'][0]['text'].trim();
        // Normalize apostrophes and quotes to ensure they display correctly
        return normalizeText(content);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate text: $e');
    }
  }

  @override
  String get providerName => 'Google Gemini';

  @override
  String get modelIdentifier => _model;
}

/// Main LLM service class that uses the provider pattern
class LLMService {
  late final LLMProvider _provider;

  /// Create service with a specific provider
  LLMService({LLMProvider? provider}) {
    if (provider != null) {
      _provider = provider;
    } else {
      // Default to OpenAI if no provider specified
      final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
      _provider = OpenAIProvider(apiKey: apiKey);
    }
  }

  /// Switch to a different provider at runtime
  void setProvider(LLMProvider provider) {
    _provider = provider;
  }

  /// Get info about current provider
  String get currentProviderInfo => '${_provider.providerName} (${_provider.modelIdentifier})';

  /// Generate a relationship question using the configured provider
  Future<String> generateRelationshipQuestion({
    // New parameters matching new prompt format
    String depthOfRelationship = 'Friends',
    String moodTone = 'Funny/Playful',
    String context = 'Casual hangout',
    String comfortLevel = 'Moderate',
    String goalOfInteraction = 'Getting to know each other better',
    String thematicCategory = 'Past experiences',
    String questionHistory = '',
    String language = 'en', // Default to English
  }) async {
    // Map language code to full language name for the prompt
    // IMPORTANT: Always use English language names in the prompt so the
    // LLM understands the instruction, but specify to generate in the target language
    final Map<String, String> languageMap = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      // Add new languages here as needed
    };

    String languageName = languageMap[language] ?? 'English';

    // Construct the improved prompt template with optimized user feedback
    // Add special handling for Preferences category to avoid food-only questions
    final String categoryGuidance =
        thematicCategory == 'Preferences'
            ? '(Choose ONE specific aspect from this category to focus on, AVOID defaulting to food preferences unless explicitly asked for)'
            : '(Choose ONE specific aspect from this category to focus on)';

    final prompt = '''
    Create a conversation-starting question for two people based on these parameters:

    Depth of Relationship: $depthOfRelationship
    Mood/Tone: $moodTone
    Context: $context
    Comfort Level: $comfortLevel
    Goal of Interaction: $goalOfInteraction
    Thematic Category: $thematicCategory $categoryGuidance
    Language: $languageName
    
    $questionHistory

    IMPORTANT GUIDELINES:
    1. Generate ONE unique, specific, and memorable question in $languageName
    2. Make the question personal, emotionally resonant, and slightly unexpected
    3. Avoid generic conversation starters or clichés - be specific and thought-provoking
    4. If the category is 'Preferences', choose from diverse topics like music, travel, leisure activities, style, career choices, books, films, art, etc. - don't default to food preferences
    5. Focus on depth and meaningful connection rather than surface-level small talk
    6. Craft a question that feels natural and conversational in $languageName
    7. Return ONLY the question with no additional text, formatting, or preamble
    8. IMPORTANT: Focus on a SINGLE thematic aspect rather than trying to cover multiple categories
    9. The question should make people think, reflect, and want to share something meaningful
    10. Pay attention to highly-rated questions in the history and learn from what users liked
    11. Keep the question short, concise and easy to understand, avoiding complex language or jargon
    12. The context should dictate the question, but not everything has to be in the question - it should feel natural and not forced
    13. Make the question just have one part, not two or three parts - it should be a single question that can be answered easily
    14. Try not to use "and" in the question - it should be a single thought or idea
    15. Don't use "and"
    16. Make sure the question covers a new aspect that hasn't been asked before in the history
    17. Be creative and think outside the box - the question should be something that people wouldn't normally think of asking each other
    18. The question should be something that people would actually want to answer and discuss
    

    YOUR RESPONSE MUST ONLY CONTAIN THE QUESTION IN $languageName LANGUAGE, NOTHING ELSE.
    ''';

    try {
      print('Prompt: $prompt'); // Debugging line to check the prompt
      return await _provider.generateText(prompt);
    } catch (e) {
      return 'Failed to generate a question. Please try again later.';
    }
  }
}

/// Factory to create predefined provider instances with keys from .env
class LLMProviderFactory {
  static LLMProvider createOpenAIProvider() {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY not found in .env file');
    }
    return OpenAIProvider(apiKey: apiKey);
  }

  static LLMProvider createAnthropicProvider() {
    final apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('ANTHROPIC_API_KEY not found in .env file');
    }
    return AnthropicProvider(apiKey: apiKey);
  }

  static LLMProvider createGeminiProvider() {
    final apiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('GOOGLE_API_KEY not found in .env file');
    }
    return GeminiProvider(apiKey: apiKey);
  }
}

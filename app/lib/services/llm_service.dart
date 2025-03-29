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
  }) async {
    // Construct the prompt with new template
    final prompt = '''
    Prompt Template for Generating Personalized Interaction Questions:

    Create a thoughtful, engaging question optimized for a conversation between two people based on the following variables:

    Depth of Relationship: $depthOfRelationship

    Mood/Tone: $moodTone

    Context: $context

    Comfort Level: $comfortLevel

    Goal of Interaction: $goalOfInteraction

    Thematic Category: $thematicCategory
    $questionHistory

    Based on these inputs, generate a unique and engaging question tailored to the described scenario.
    Return only the question with no additional text, formatting, or preamble.
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

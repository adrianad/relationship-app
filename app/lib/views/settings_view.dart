import 'package:app/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/question_provider.dart';
import 'package:app/generated/app_localizations.dart';
import 'package:app/widgets/language_selector.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Selected LLM provider
  String _selectedProvider = 'OpenAI';
  final List<String> _providers = ['OpenAI', 'Anthropic', 'Gemini'];
  
  // Helper function to get localized text for options while keeping original values for the prompt
  String getLocalizedOption(BuildContext context, String option) {
    final localizations = AppLocalizations.of(context);
    
    // LLM Provider
    if (option == 'OpenAI') return localizations.openAiProvider;
    if (option == 'Anthropic') return localizations.anthropicProvider;
    if (option == 'Gemini') return localizations.geminiProvider;
    
    // Default fallback
    return option;
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final localizations = AppLocalizations.of(context);

    // Access the active profile via the profile provider
    final activeProfile = profileProvider.activeProfile;
    if (activeProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.settings),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(localizations.noActiveProfile),
        ),
      );
    }

    // Initialize values from provider
    _selectedProvider = questionProvider.currentProvider;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsFor(activeProfile.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: localizations.manageProfiles,
            onPressed: () {
              Navigator.pushNamed(context, '/profiles');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selector
            const LanguageSelector(),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            
            Text(localizations.questionGenerationSettings, 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // LLM Provider selection
            Text(localizations.llmProvider, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              localizations.selectAiProviderHint,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items:
                  _providers.map((provider) {
                    return DropdownMenuItem(
                      value: provider, 
                      child: Text(getLocalizedOption(context, provider))
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvider = value!;
                });
              },
            ),

            const SizedBox(height: 40),

            // Apply settings button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveSettings(questionProvider, context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12), 
                  child: Text(localizations.applySettings)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings(QuestionProvider provider, BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    
    // Update the provider selection if changed
    if (provider.currentProvider != _selectedProvider) {
      await provider.setProvider(_selectedProvider);
    }

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text(localizations.settingsUpdatedSuccessfully), 
        duration: const Duration(seconds: 2)
      ));
    }
  }
}
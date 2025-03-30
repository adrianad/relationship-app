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

  // Selected options for multi-selects
  List<String> _selectedMoodTone = ['Funny/Playful'];
  List<String> _selectedGoals = ['Getting to know each other better'];
  List<String> _selectedCategories = ['Past experiences'];
  
  // Helper function to get localized text for options while keeping original values for the prompt
  String getLocalizedOption(BuildContext context, String option) {
    final localizations = AppLocalizations.of(context);
    
    // LLM Provider
    if (option == 'OpenAI') return localizations.openAiProvider;
    if (option == 'Anthropic') return localizations.anthropicProvider;
    if (option == 'Gemini') return localizations.geminiProvider;
    
    // Depth Options
    if (option == 'Acquaintances') return localizations.depthAcquaintances;
    if (option == 'Friends') return localizations.depthFriends;
    if (option == 'Close Friends') return localizations.depthCloseFriends;
    if (option == 'Partners/Lovers') return localizations.depthPartners;
    
    // Mood/Tone Options
    if (option == 'Funny/Playful') return localizations.moodFunny;
    if (option == 'Serious/Thoughtful') return localizations.moodSerious;
    if (option == 'Deep/Reflective') return localizations.moodDeep;
    if (option == 'Sensual/Intimate') return localizations.moodSensual;
    if (option == 'Crazy/Absurd') return localizations.moodCrazy;
    if (option == 'Provocative/Dirty') return localizations.moodProvocative;
    
    // Context Options
    if (option == 'Casual hangout') return localizations.contextCasual;
    if (option == 'Date night') return localizations.contextDate;
    if (option == 'Online chat') return localizations.contextOnline;
    if (option == 'Party setting') return localizations.contextParty;
    if (option == 'Private/intimate setting') return localizations.contextPrivate;
    if (option == 'Road trip') return localizations.contextRoadTrip;
    if (option == 'Dinner conversation') return localizations.contextDinner;
    
    // Comfort Options
    if (option == 'Safe (low risk)') return localizations.comfortSafe;
    if (option == 'Moderate') return localizations.comfortModerate;
    if (option == 'High Risk') return localizations.comfortHighRisk;
    
    // Goal Options
    if (option == 'Getting to know each other better') return localizations.goalGettingToKnow;
    if (option == 'Deepening intimacy') return localizations.goalDeepening;
    if (option == 'Breaking the ice') return localizations.goalBreakingIce;
    if (option == 'Stimulating thoughtful discussion') return localizations.goalThoughtful;
    if (option == 'Provoking humor/playfulness') return localizations.goalHumor;
    if (option == 'Exploring fantasies/desires') return localizations.goalFantasies;
    
    // Category Options
    if (option == 'Past experiences') return localizations.categoryPast;
    if (option == 'Personal values/beliefs') return localizations.categoryValues;
    if (option == 'Hypothetical scenarios') return localizations.categoryHypothetical;
    if (option == 'Dreams/goals/ambitions') return localizations.categoryDreams;
    if (option == 'Preferences') return localizations.categoryPreferences;
    if (option == 'Relationships/intimacy') return localizations.categoryRelationships;
    if (option == 'Secrets/confessions') return localizations.categorySecrets;
    
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
    _selectedMoodTone = List.from(questionProvider.moodTone);
    _selectedGoals = List.from(questionProvider.goalOfInteraction);
    _selectedCategories = List.from(questionProvider.thematicCategory);

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

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Depth of Relationship
            Text(localizations.depthOfRelationship, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(localizations.howWellPeopleKnowEachOther, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: questionProvider.depthOfRelationship,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items:
                  questionProvider.depthOptions.map((option) {
                    return DropdownMenuItem(
                      value: option, 
                      child: Text(getLocalizedOption(context, option))
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  questionProvider.updateSettings(depthOfRelationship: value);
                }
              },
            ),

            const SizedBox(height: 24),

            // Mood/Tone (multi-select)
            Text(localizations.moodTone, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              localizations.selectTonesForQuestions,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  questionProvider.moodOptions.map((option) {
                    final isSelected = _selectedMoodTone.contains(option);
                    return FilterChip(
                      label: Text(getLocalizedOption(context, option)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedMoodTone.add(option);
                          } else {
                            _selectedMoodTone.remove(option);
                          }
                          // Don't allow empty selection
                          if (_selectedMoodTone.isEmpty) {
                            _selectedMoodTone.add(option);
                          }
                          questionProvider.updateSettings(moodTone: _selectedMoodTone);
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // Context
            Text(localizations.context, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              localizations.settingForConversation,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: questionProvider.context,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items:
                  questionProvider.contextOptions.map((option) {
                    return DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option)));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  questionProvider.updateSettings(context: value);
                }
              },
            ),

            const SizedBox(height: 24),

            // Comfort Level
            Text(localizations.comfortLevel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              localizations.howChallengingQuestionsBecome,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: questionProvider.comfortLevel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items:
                  questionProvider.comfortOptions.map((option) {
                    return DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option)));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  questionProvider.updateSettings(comfortLevel: value);
                }
              },
            ),

            const SizedBox(height: 24),

            // Goal of Interaction (multi-select)
            Text(localizations.goalOfInteraction, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              localizations.whatQuestionsAccomplish,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  questionProvider.goalOptions.map((option) {
                    final isSelected = _selectedGoals.contains(option);
                    return FilterChip(
                      label: Text(getLocalizedOption(context, option)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedGoals.add(option);
                          } else {
                            _selectedGoals.remove(option);
                          }
                          // Don't allow empty selection
                          if (_selectedGoals.isEmpty) {
                            _selectedGoals.add(option);
                          }
                          questionProvider.updateSettings(goalOfInteraction: _selectedGoals);
                        });
                      },
                    );
                  }).toList(),
            ),

            const SizedBox(height: 24),

            // Thematic Category (multi-select)
            Text(localizations.thematicCategory, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              localizations.topicsQuestionsShoulCover,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  questionProvider.categoryOptions.map((option) {
                    final isSelected = _selectedCategories.contains(option);
                    return FilterChip(
                      label: Text(getLocalizedOption(context, option)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(option);
                          } else {
                            _selectedCategories.remove(option);
                          }
                          // Don't allow empty selection
                          if (_selectedCategories.isEmpty) {
                            _selectedCategories.add(option);
                          }
                          questionProvider.updateSettings(thematicCategory: _selectedCategories);
                        });
                      },
                    );
                  }).toList(),
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

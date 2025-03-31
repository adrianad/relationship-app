import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/question_provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/generated/app_localizations.dart';

class QuestionsView extends StatefulWidget {
  final String questionText;

  const QuestionsView({super.key, this.questionText = "How was your day today?"});

  @override
  State<QuestionsView> createState() => _QuestionsViewState();
}

// Preset class to represent available presets
class Preset {
  final String name;
  final IconData icon;
  final Color color;
  final String moodTone;
  final String category;
  final String goal;
  final Function(BuildContext) onApply;
  
  const Preset({
    required this.name,
    required this.icon,
    required this.color,
    required this.moodTone,
    required this.category,
    required this.goal,
    required this.onApply,
  });
}

class _QuestionsViewState extends State<QuestionsView> {
  late String _currentQuestion;
  int _rating = 3; // Default rating set to 3 stars
  bool _isLoading = false;
  String? _error;
  
  // We keep only the essential feedback options
  bool _moreLikeThis = false;
  bool _lessLikeThis = false;
  
  // Settings panel state
  bool _showSettingsPanel = false;
  
  // Keep track of current settings for parameter display
  String _currentMoodTone = 'Funny/Playful';
  String _currentCategory = 'Past experiences';
  String _currentComfortLevel = 'Moderate';
  String _currentGoal = 'Getting to know each other better';
  
  // Random selection flags are now in profile
  
  // Temporary settings for display only (used by presets)
  String _tempMoodTone = '';
  String _tempCategory = '';
  String _tempDepth = '';
  String _tempGoal = '';
  bool _showingTempSettings = false;
  
  // Preset selection functionality
  String _activePreset = 'Funny'; // Default preset

  // Define list of available presets
  late List<Preset> _presets;
  
  // Initialize presets
  void _initializePresets() {
    _presets = [
      Preset(
        name: 'Funny',
        icon: Icons.lightbulb,
        color: Colors.amber.shade600,
        moodTone: 'Funny/Playful',
        category: 'Hypothetical scenarios',
        goal: 'Provoking humor/playfulness',
        onApply: (context) => _generateFunnyQuestion(),
      ),
      Preset(
        name: 'Deep',
        icon: Icons.psychology,
        color: Colors.grey.shade700,
        moodTone: 'Deep/Reflective',
        category: 'Personal values/beliefs',
        goal: 'Stimulating thoughtful discussion',
        onApply: (context) => _generateDeepQuestion(),
      ),
      Preset(
        name: 'Icebreaker',
        icon: Icons.ac_unit,
        color: Colors.teal.shade600,
        moodTone: 'Funny/Playful',
        category: 'Preferences',
        goal: 'Breaking the ice',
        onApply: (context) => _generateIcebreakerQuestion(),
      ),
      Preset(
        name: 'Random',
        icon: Icons.shuffle,
        color: Colors.indigo.shade500,
        moodTone: 'Random',
        category: 'Random',
        goal: 'Random',
        onApply: (context) => _generateRandomQuestion(),
      ),
    ];
  }
  
  // Get the currently active preset object
  Preset get _currentPreset => _presets.firstWhere(
    (preset) => preset.name == _activePreset,
    orElse: () => _presets.first
  );
  
  // Apply the selected preset
  void _applyPreset(Preset preset) {
    preset.onApply(context);
  }
  
  // Set a new active preset
  void _setActivePreset(String presetName) {
    setState(() {
      _activePreset = presetName;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.questionText;
    _initializePresets();
    
    // We need to use a post-frame callback for any provider access in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      
      // Debug - log current profile settings
      questionProvider.printProfileSettings();
      
      // Make sure the question provider has the correct language
      questionProvider.updateDefaultQuestion(languageProvider.currentLocale.languageCode);
      
      // Initialize with the current question from provider
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        
        // Initialize current settings for parameter display from the active profile
        if (questionProvider.anyMoodTone) {
          _currentMoodTone = 'Random';
        } else if (questionProvider.moodTone.isNotEmpty) {
          _currentMoodTone = questionProvider.moodTone.first;
        }
        
        if (questionProvider.anyCategory) {
          _currentCategory = 'Random';
        } else if (questionProvider.thematicCategory.isNotEmpty) {
          _currentCategory = questionProvider.thematicCategory.first;
        }
        
        if (questionProvider.anyGoal) {
          _currentGoal = 'Random';
        } else if (questionProvider.goalOfInteraction.isNotEmpty) {
          _currentGoal = questionProvider.goalOfInteraction.first;
        }
        _currentComfortLevel = questionProvider.comfortLevel;
        
        // Debug log
        print('Initialized UI state with:');
        print('- _currentMoodTone: $_currentMoodTone');
        print('- _currentCategory: $_currentCategory'); 
        print('- _currentGoal: $_currentGoal');
      });
    });
  }

  void _loadNewQuestion() async {
    await _generateQuestion();
  }
  
  // Generate with current settings
  Future<void> _generateQuestion() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Debug - log settings before generating
    print('Generating new question with saved settings:');
    questionProvider.printProfileSettings();
    
    // Get the default question for the current language
    final defaultQuestion = questionProvider.getDefaultQuestion(
      languageProvider.currentLocale.languageCode
    );
    
    // First, save current question's feedback to history (if it's not the default question)
    if (_currentQuestion != defaultQuestion) {
      await questionProvider.saveQuestionToHistory(
        rating: _rating,
        moreLikeThis: _moreLikeThis,
        lessLikeThis: _lessLikeThis,
      );
    }
    
    setState(() {
      _isLoading = true;
      // Clear any temporary settings when generating a question with real settings
      _showingTempSettings = false;
    });
    
    try {
      // Make sure any UI changes to settings are explicitly saved to the profile
      // before generating the question
      if (!questionProvider.anyMoodTone && _currentMoodTone != questionProvider.moodTone.first) {
        await questionProvider.updateSettings(
          anyMoodTone: false,
          moodTone: [_currentMoodTone]
        );
      }
      
      if (!questionProvider.anyCategory && _currentCategory != questionProvider.thematicCategory.first) {
        await questionProvider.updateSettings(
          anyCategory: false,
          thematicCategory: [_currentCategory]
        );
      }
      
      if (!questionProvider.anyGoal && _currentGoal != questionProvider.goalOfInteraction.first) {
        await questionProvider.updateSettings(
          anyGoal: false,
          goalOfInteraction: [_currentGoal]
        );
      }
      
      // Load new question from the question provider with current language
      // Using the user's saved settings (as stored in the profile)
      await questionProvider.generateQuestion(
        language: languageProvider.currentLocale.languageCode,
        // Use the user's saved settings
        anyMoodTone: questionProvider.anyMoodTone,
        anyCategory: questionProvider.anyCategory,
        anyGoal: questionProvider.anyGoal,
        // Explicitly set temporaryRandom to false to use saved settings
        temporaryRandom: false
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3; // Reset rating to default 3 stars for new question
        _moreLikeThis = false; // Reset button state
        _lessLikeThis = false; // Reset button state
        
        // Update current settings for parameter display from the saved profile settings
        if (questionProvider.anyMoodTone) {
          _currentMoodTone = 'Random';
        } else if (questionProvider.moodTone.isNotEmpty) {
          _currentMoodTone = questionProvider.moodTone.first;
        }
        
        if (questionProvider.anyCategory) {
          _currentCategory = 'Random';
        } else if (questionProvider.thematicCategory.isNotEmpty) {
          _currentCategory = questionProvider.thematicCategory.first;
        }
        
        if (questionProvider.anyGoal) {
          _currentGoal = 'Random';
        } else if (questionProvider.goalOfInteraction.isNotEmpty) {
          _currentGoal = questionProvider.goalOfInteraction.first;
        }
        _currentComfortLevel = questionProvider.comfortLevel;
        
        _isLoading = false;
        _error = null; // Clear any previous errors
      });
      
      // Debug - log settings after generating
      print('Settings after question generation:');
      questionProvider.printProfileSettings();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  // Generate with same settings
  Future<void> _regenerateWithSameSettings() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Get the default question for the current language
    final defaultQuestion = questionProvider.getDefaultQuestion(
      languageProvider.currentLocale.languageCode
    );
    
    // First, save current question's feedback to history (if it's not the default question)
    if (_currentQuestion != defaultQuestion) {
      await questionProvider.saveQuestionToHistory(
        rating: _rating,
        moreLikeThis: _moreLikeThis,
        lessLikeThis: _lessLikeThis,
      );
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Regenerate with same settings
      await questionProvider.regenerateWithSameSettings(
        language: languageProvider.currentLocale.languageCode
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3; // Reset rating to default 3 stars for new question
        _moreLikeThis = false; // Reset button state
        _lessLikeThis = false; // Reset button state
        _isLoading = false;
        _error = null; // Clear any previous errors
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // Generate with preset: Funny
  Future<void> _generateFunnyQuestion() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Save current feedback first
    await _saveFeedbackIfNeeded();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Don't update profile settings, just use preset temporarily
      await questionProvider.generateFunnyQuestion(
        language: languageProvider.currentLocale.languageCode
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3;
        _moreLikeThis = false;
        _lessLikeThis = false;
        // Just show temporary parameters in UI, don't actually modify settings
        _tempMoodTone = 'Funny/Playful';
        _tempCategory = 'Hypothetical scenarios';
        _tempGoal = 'Provoking humor/playfulness';
        _showingTempSettings = true;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  // Generate with preset: Deep
  Future<void> _generateDeepQuestion() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Save current feedback first
    await _saveFeedbackIfNeeded();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Don't update profile settings, just use preset temporarily
      await questionProvider.generateDeepQuestion(
        language: languageProvider.currentLocale.languageCode
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3;
        _moreLikeThis = false;
        _lessLikeThis = false;
        // Just show temporary parameters in UI, don't actually modify settings
        _tempMoodTone = 'Deep/Reflective';
        _tempCategory = 'Personal values/beliefs';
        _tempGoal = 'Stimulating thoughtful discussion';
        _showingTempSettings = true;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  // Generate with preset: Icebreaker
  Future<void> _generateIcebreakerQuestion() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Save current feedback first
    await _saveFeedbackIfNeeded();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Don't update profile settings, just use preset temporarily
      await questionProvider.generateIcebreakerQuestion(
        language: languageProvider.currentLocale.languageCode
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3;
        _moreLikeThis = false;
        _lessLikeThis = false;
        // Just show temporary parameters in UI, don't actually modify settings
        _tempMoodTone = 'Funny/Playful';
        _tempCategory = 'Preferences';
        _tempGoal = 'Breaking the ice';
        _showingTempSettings = true;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  // Generate completely random question
  Future<void> _generateRandomQuestion() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Save current feedback first
    await _saveFeedbackIfNeeded();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Don't update profile settings, just use random temporarily
      // Generate a question with random settings
      await questionProvider.generateRandomQuestion(
        language: languageProvider.currentLocale.languageCode
      );
      
      // Update local state with the new settings
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3;
        _moreLikeThis = false;
        _lessLikeThis = false;
        
        // Just show temporary parameters in UI, don't actually modify settings
        _tempMoodTone = 'Random';
        _tempCategory = 'Random';
        _tempGoal = 'Random';
        _tempDepth = '';  // Don't show any depth change
        _showingTempSettings = true;
        
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  // Helper method to save feedback if needed
  Future<void> _saveFeedbackIfNeeded() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Get the default question for the current language
    final defaultQuestion = questionProvider.getDefaultQuestion(
      languageProvider.currentLocale.languageCode
    );
    
    // First, save current question's feedback to history (if it's not the default question)
    if (_currentQuestion != defaultQuestion) {
      await questionProvider.saveQuestionToHistory(
        rating: _rating,
        moreLikeThis: _moreLikeThis,
        lessLikeThis: _lessLikeThis,
      );
    }
  }

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
    
    // Save updated data to database
    _saveCurrentFeedback();
  }

  void _toggleMoreLikeThis() {
    setState(() {
      _moreLikeThis = true;
      _lessLikeThis = false;
    });
    
    // Save updated data to database
    _saveCurrentFeedback();
  }

  void _toggleLessLikeThis() {
    setState(() {
      _lessLikeThis = true;
      _moreLikeThis = false;
    });
    
    // Save updated data to database
    _saveCurrentFeedback();
  }
  
  void _toggleSettingsPanel() {
    setState(() {
      _showSettingsPanel = !_showSettingsPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final questionProvider = Provider.of<QuestionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.relationshipQuestions),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: localizations.manageProfiles,
            onPressed: () {
              Navigator.pushNamed(context, '/profiles');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: localizations.settings,
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
              // Quick Settings Panel Toggle Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(_showSettingsPanel ? Icons.expand_less : Icons.expand_more),
                    label: Text(_showSettingsPanel ? 'Hide Settings' : 'Show Settings'),
                    onPressed: _toggleSettingsPanel,
                  ),
                ],
              ),
              
              // Quick Settings Panel (collapsible)
              if (_showSettingsPanel)
                Card(
                  elevation: 2,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizations.questionGenerationSettings, 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        
                        const SizedBox(height: 12),
                        const Divider(),
                        
                        // Quick settings for mood
                        Text(localizations.moodTone, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // "Random" option for mood - treat as a regular category
                            ChoiceChip(
                              label: Text('Random', style: TextStyle(
                                fontSize: 12,
                                color: questionProvider.anyMoodTone ? Colors.white : null,
                              )),
                              selected: questionProvider.anyMoodTone,
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: Colors.blueGrey.shade600,
                              onSelected: (_) async {
                                print('Selecting Random mood/tone');
                                // Select Random regardless of previous state
                                await questionProvider.updateSettings(
                                  anyMoodTone: true,
                                  moodTone: [questionProvider.moodOptions.first] // Default fallback
                                );
                                setState(() {
                                  _currentMoodTone = 'Random';
                                });
                                // Debug - confirm update
                                questionProvider.printProfileSettings();
                              },
                            ),
                            ...questionProvider.moodOptions
                              .map((option) => ChoiceChip(
                                    label: Text(getLocalizedOption(context, option), style: TextStyle(
                                      fontSize: 12,
                                      color: (!questionProvider.anyMoodTone && _currentMoodTone == option) ? Colors.white : null,
                                    )),
                                    selected: !questionProvider.anyMoodTone && _currentMoodTone == option,
                                    selectedColor: Colors.blueGrey.shade600,
                                    backgroundColor: Colors.grey.shade200,
                                    onSelected: (_) async {
                                      // Simply select this option and turn off Random
                                      await questionProvider.updateSettings(
                                        anyMoodTone: false, // Turn off Random
                                        moodTone: [option],
                                      );
                                      setState(() {
                                        _currentMoodTone = option;
                                      });
                                    },
                                  ))
                              .toList(),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Quick settings for category
                        Text(localizations.thematicCategory, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // "Random" option for category - treat as a regular category
                            ChoiceChip(
                              label: Text('Random', style: TextStyle(
                                fontSize: 12,
                                color: questionProvider.anyCategory ? Colors.white : null,
                              )),
                              selected: questionProvider.anyCategory,
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: Colors.blueGrey.shade600,
                              onSelected: (_) async {
                                print('Selecting Random category');
                                // Select Random regardless of previous state
                                await questionProvider.updateSettings(
                                  anyCategory: true,
                                  thematicCategory: [questionProvider.categoryOptions.first] // Default fallback
                                );
                                setState(() {
                                  _currentCategory = 'Random';
                                });
                                // Debug - confirm update
                                questionProvider.printProfileSettings();
                              },
                            ),
                            ...questionProvider.categoryOptions
                              .map((option) => ChoiceChip(
                                    label: Text(getLocalizedOption(context, option), style: TextStyle(
                                      fontSize: 12,
                                      color: (!questionProvider.anyCategory && _currentCategory == option) ? Colors.white : null,
                                    )),
                                    selected: !questionProvider.anyCategory && _currentCategory == option,
                                    selectedColor: Colors.blueGrey.shade600,
                                    backgroundColor: Colors.grey.shade200,
                                    onSelected: (_) async {
                                      // Simply select this option and turn off Random
                                      print('Selecting category: $option');
                                      await questionProvider.updateSettings(
                                        anyCategory: false, // Turn off Random
                                        thematicCategory: [option],
                                      );
                                      setState(() {
                                        _currentCategory = option;
                                      });
                                      // Debug - confirm update
                                      questionProvider.printProfileSettings();
                                    },
                                  ))
                              .toList(),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        const SizedBox(height: 8),
                        
                        // Quick settings for goal of interaction
                        Text(localizations.goalOfInteraction, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // "Random" option for goal - treat as a regular category
                            ChoiceChip(
                              label: Text('Random', style: TextStyle(
                                fontSize: 12,
                                color: questionProvider.anyGoal ? Colors.white : null,
                              )),
                              selected: questionProvider.anyGoal,
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: Colors.blueGrey.shade600,
                              onSelected: (_) async {
                                print('Selecting Random goal');
                                // Select Random regardless of previous state
                                await questionProvider.updateSettings(
                                  anyGoal: true,
                                  goalOfInteraction: [questionProvider.goalOptions.first] // Default fallback
                                );
                                setState(() {
                                  _currentGoal = 'Random';
                                });
                                // Debug - confirm update
                                questionProvider.printProfileSettings();
                              },
                            ),
                            ...questionProvider.goalOptions
                              .map((option) => ChoiceChip(
                                label: Text(getLocalizedOption(context, option), style: TextStyle(
                                  fontSize: 12,
                                  color: (!questionProvider.anyGoal && _currentGoal == option) ? Colors.white : null,
                                )),
                                selected: !questionProvider.anyGoal && _currentGoal == option,
                                selectedColor: Colors.blueGrey.shade600,
                                backgroundColor: Colors.grey.shade200,
                                onSelected: (_) async {
                                  // Simply select this option and turn off Random
                                  print('Selecting goal: $option');
                                  await questionProvider.updateSettings(
                                    anyGoal: false, // Turn off Random
                                    goalOfInteraction: [option],
                                  );
                                  setState(() {
                                    _currentGoal = option;
                                  });
                                  // Debug - confirm update
                                  questionProvider.printProfileSettings();
                                },
                              ))
                              .toList(),
                          ],
                        ),
                      ],
                      ),
                    ),
                  ),
                ),
                
              const SizedBox(height: 12),
              
              // Context dropdown outside the settings panel
              Row(
                children: [
                  const Icon(Icons.place, size: 18),
                  const SizedBox(width: 8),
                  Text(localizations.context, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: questionProvider.context,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        isDense: true,
                      ),
                      items: questionProvider.contextOptions
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(getLocalizedOption(context, option), style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          await questionProvider.updateSettings(context: value);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              
              // Parameter chips above the question
              Wrap(
                spacing: 6,
                children: [
                  // If showing temporary settings from presets, show those instead
                  if (_showingTempSettings) ...[  
                    if (_tempMoodTone.isNotEmpty) Chip(
                      label: Text(_tempMoodTone == 'Random' 
                        ? 'Random${questionProvider.lastRandomMoodTone != null ? ': ${getLocalizedOption(context, questionProvider.lastRandomMoodTone!)}' : ''}'
                        : getLocalizedOption(context, _tempMoodTone)),
                      avatar: const Icon(Icons.mood, size: 16),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: _tempMoodTone == 'Random' ? Colors.indigo.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                    ),
                    if (_tempCategory.isNotEmpty) Chip(
                      label: Text(_tempCategory == 'Random' 
                        ? 'Random${questionProvider.lastRandomCategory != null ? ': ${getLocalizedOption(context, questionProvider.lastRandomCategory!)}' : ''}'
                        : getLocalizedOption(context, _tempCategory)),
                      avatar: const Icon(Icons.category, size: 16),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: _tempCategory == 'Random' ? Colors.indigo.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                    ),
                    if (_tempDepth.isNotEmpty) Chip(
                      label: Text(getLocalizedOption(context, _tempDepth)),
                      avatar: const Icon(Icons.people, size: 16),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: Colors.amber.withOpacity(0.2),
                    ),
                    if (_tempGoal.isNotEmpty) Chip(
                      label: Text(_tempGoal == 'Random' 
                        ? 'Random${questionProvider.lastRandomGoal != null ? ': ${getLocalizedOption(context, questionProvider.lastRandomGoal!)}' : ''}'
                        : getLocalizedOption(context, _tempGoal)),
                      avatar: const Icon(Icons.flag, size: 16),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: _tempGoal == 'Random' ? Colors.indigo.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                    ),
                  ] else ...[  
                    // Otherwise show the actual settings
                    Chip(
                      label: Text(questionProvider.anyMoodTone
                        ? 'Random${questionProvider.lastRandomMoodTone != null ? ': ${getLocalizedOption(context, questionProvider.lastRandomMoodTone!)}' : ''}'
                        : getLocalizedOption(context, _currentMoodTone)),
                      avatar: const Icon(Icons.mood, size: 16),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: questionProvider.anyMoodTone ? Colors.indigo.withOpacity(0.2) : Colors.grey.shade200,
                    ),
                    Chip(
                      label: Text(questionProvider.anyCategory
                        ? 'Random${questionProvider.lastRandomCategory != null ? ': ${getLocalizedOption(context, questionProvider.lastRandomCategory!)}' : ''}'
                        : getLocalizedOption(context, _currentCategory)),
                      avatar: const Icon(Icons.category, size: 16),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: questionProvider.anyCategory ? Colors.indigo.withOpacity(0.2) : Colors.grey.shade200,
                    ),
                    Chip(
                      label: Text(questionProvider.anyGoal
                        ? 'Random${questionProvider.lastRandomGoal != null ? ': ${getLocalizedOption(context, questionProvider.lastRandomGoal!)}' : ''}'
                        : getLocalizedOption(context, _currentGoal)),
                      avatar: const Icon(Icons.flag, size: 16),
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: questionProvider.anyGoal ? Colors.indigo.withOpacity(0.2) : Colors.grey.shade200,
                    ),
                  ],
                  // Only show comfort level if not moved to profile settings
                  // Chip(
                  //   label: Text(getLocalizedOption(context, _currentComfortLevel)),
                  //   avatar: const Icon(Icons.safety_divider, size: 16),
                  //   visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  //   labelStyle: const TextStyle(fontSize: 12),
                  // ),
                ],
              ),
                
              const SizedBox(height: 12),

              // Chat bubble with question or loading indicator
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey.shade100, Colors.grey.shade200],
                    ),
                  ),
                  child: _isLoading 
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Text(
                        _error != null
                          ? localizations.errorLoadingQuestion
                          : _currentQuestion,
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              // Two response buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleLessLikeThis,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        backgroundColor: _lessLikeThis ? Colors.grey.shade300 : Colors.transparent,
                      ),
                      child: Text(localizations.lessLikeThis, style: TextStyle(color: Colors.grey.shade700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleMoreLikeThis,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        backgroundColor: _moreLikeThis ? Colors.grey.shade300 : Colors.transparent,
                      ),
                      child: Text(localizations.moreLikeThis, style: TextStyle(color: Colors.grey.shade700)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Star rating
              Column(
                children: [
                  Text(localizations.rateThisQuestion),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () => _setRating(index + 1),
                      );
                    }),
                  ),
                ],
              ),
              
              // Add some spacing between rating and buttons
              const SizedBox(height: 20),
              
              // Split button for preset selection
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPreset.color,
                        ),
                        child: Row(
                          children: [
                            // Main button part (left side) - applies the current preset
                            Expanded(
                              flex: 5,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _applyPreset(_currentPreset),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(_currentPreset.icon, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          _currentPreset.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Vertical divider
                            Container(
                              height: 28,
                              width: 1,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            // Dropdown toggle part (right side) - shows preset options
                            Expanded(
                              flex: 1,
                              child: PopupMenuButton<String>(
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                onSelected: _setActivePreset,
                                itemBuilder: (context) => _presets.map((preset) => 
                                  PopupMenuItem<String>(
                                    value: preset.name,
                                    child: Row(
                                      children: [
                                        Icon(preset.icon, color: preset.color, size: 18),
                                        const SizedBox(width: 8),
                                        Text(preset.name),
                                      ],
                                    ),
                                  )
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // My Settings button with same style as presets
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.blueGrey.shade600,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _loadNewQuestion,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.settings_suggest, color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'New Question',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
  
  // Save current feedback to database
  void _saveCurrentFeedback() {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    
    // Get the default question for the current language
    final defaultQuestion = questionProvider.getDefaultQuestion(
      languageProvider.currentLocale.languageCode
    );
    
    // Skip if this is the default question
    if (_currentQuestion == defaultQuestion) return;
    
    questionProvider.saveQuestionToHistory(
      rating: _rating,
      moreLikeThis: _moreLikeThis,
      lessLikeThis: _lessLikeThis,
    );
  }
  
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
    if (option == 'Neutral/Balanced') return 'Neutral';  // Using direct string since we don't have localization yet
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
}

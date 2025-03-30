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
  
  // Track if "Anything" is selected for different categories
  bool _anyMoodTone = false;
  bool _anyCategory = false;
  bool _anyGoal = false;

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.questionText;
    
    // We need to use a post-frame callback for any provider access in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      
      // Make sure the question provider has the correct language
      questionProvider.updateDefaultQuestion(languageProvider.currentLocale.languageCode);
      
      // Initialize with the current question from provider
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        
        // Initialize current settings for parameter display
        if (questionProvider.moodTone.isNotEmpty) {
          _currentMoodTone = questionProvider.moodTone.first;
        }
        if (questionProvider.thematicCategory.isNotEmpty) {
          _currentCategory = questionProvider.thematicCategory.first;
        }
        if (questionProvider.goalOfInteraction.isNotEmpty) {
          _currentGoal = questionProvider.goalOfInteraction.first;
        }
        _currentComfortLevel = questionProvider.comfortLevel;
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
      // Load new question from the question provider with current language
      await questionProvider.generateQuestion(
        language: languageProvider.currentLocale.languageCode,
        anyMoodTone: _anyMoodTone,
        anyCategory: _anyCategory,
        anyGoal: _anyGoal
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3; // Reset rating to default 3 stars for new question
        _moreLikeThis = false; // Reset button state
        _lessLikeThis = false; // Reset button state
        
        // Update current settings for parameter display if not "Anything"
        if (!_anyMoodTone && questionProvider.moodTone.isNotEmpty) {
          _currentMoodTone = questionProvider.moodTone.first;
        }
        if (!_anyCategory && questionProvider.thematicCategory.isNotEmpty) {
          _currentCategory = questionProvider.thematicCategory.first;
        }
        if (!_anyGoal && questionProvider.goalOfInteraction.isNotEmpty) {
          _currentGoal = questionProvider.goalOfInteraction.first;
        }
        _currentComfortLevel = questionProvider.comfortLevel;
        
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
      await questionProvider.generateFunnyQuestion(
        language: languageProvider.currentLocale.languageCode
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3;
        _moreLikeThis = false;
        _lessLikeThis = false;
        _currentMoodTone = 'Funny/Playful';
        _currentCategory = 'Hypothetical scenarios';
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
      await questionProvider.generateDeepQuestion(
        language: languageProvider.currentLocale.languageCode
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3;
        _moreLikeThis = false;
        _lessLikeThis = false;
        _currentMoodTone = 'Deep/Reflective';
        _currentCategory = 'Personal values/beliefs';
        _currentComfortLevel = 'Moderate';
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
      await questionProvider.generateIcebreakerQuestion(
        language: languageProvider.currentLocale.languageCode
      );
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 3;
        _moreLikeThis = false;
        _lessLikeThis = false;
        _currentMoodTone = 'Funny/Playful';
        _currentCategory = 'Preferences';
        _currentComfortLevel = 'Safe (low risk)';
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
      
      // Use the "Anything" options for all fields
      _anyMoodTone = true;
      _anyCategory = true;
      _anyGoal = true;
    });
    
    try {
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
        _currentComfortLevel = questionProvider.comfortLevel;
        
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
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizations.questionGenerationSettings, 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        
                        // No need for preset buttons here - moved below the question
                        
                        const SizedBox(height: 12),
                        const Divider(),
                        
                        // Quick settings for mood
                        Text(localizations.moodTone, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // "Anything" option for mood
                            ChoiceChip(
                              label: Text('Anything', style: TextStyle(
                                fontSize: 12,
                                color: _anyMoodTone ? Colors.white : null,
                              )),
                              selected: _anyMoodTone,
                              backgroundColor: Colors.purple.withOpacity(0.2),
                              selectedColor: Colors.purple,
                              onSelected: (selected) async {
                                setState(() {
                                  _anyMoodTone = selected;
                                });
                              },
                            ),
                            ...questionProvider.moodOptions
                              .map((option) => ChoiceChip(
                                    label: Text(getLocalizedOption(context, option), style: TextStyle(
                                      fontSize: 12,
                                      color: (!_anyMoodTone && _currentMoodTone == option) ? Colors.white : null,
                                    )),
                                    selected: !_anyMoodTone && _currentMoodTone == option,
                                    onSelected: (_) async {
                                      await questionProvider.updateSettings(
                                        moodTone: [option],
                                      );
                                      setState(() {
                                        _currentMoodTone = option;
                                        _anyMoodTone = false;
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
                            // "Anything" option for category
                            ChoiceChip(
                              label: Text('Anything', style: TextStyle(
                                fontSize: 12,
                                color: _anyCategory ? Colors.white : null,
                              )),
                              selected: _anyCategory,
                              backgroundColor: Colors.purple.withOpacity(0.2),
                              selectedColor: Colors.purple,
                              onSelected: (selected) async {
                                setState(() {
                                  _anyCategory = selected;
                                });
                              },
                            ),
                            ...questionProvider.categoryOptions
                              .map((option) => ChoiceChip(
                                    label: Text(getLocalizedOption(context, option), style: TextStyle(
                                      fontSize: 12,
                                      color: (!_anyCategory && _currentCategory == option) ? Colors.white : null,
                                    )),
                                    selected: !_anyCategory && _currentCategory == option,
                                    onSelected: (_) async {
                                      await questionProvider.updateSettings(
                                        thematicCategory: [option],
                                      );
                                      setState(() {
                                        _currentCategory = option;
                                        _anyCategory = false;
                                      });
                                    },
                                  ))
                              .toList(),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Quick settings for context
                        Text(localizations.context, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
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
                        
                        const SizedBox(height: 8),
                        
                        // Quick settings for comfort level
                        Row(
                          children: [
                            Text(localizations.comfortLevel, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SegmentedButton<String>(
                                segments: questionProvider.comfortOptions
                                    .map((option) => ButtonSegment<String>(
                                          value: option,
                                          label: Text(getLocalizedOption(context, option), style: const TextStyle(fontSize: 10)),
                                        ))
                                    .toList(),
                                selected: {_currentComfortLevel},
                                onSelectionChanged: (Set<String> selection) async {
                                  final selectedLevel = selection.first;
                                  await questionProvider.updateSettings(
                                    comfortLevel: selectedLevel,
                                  );
                                  setState(() {
                                    _currentComfortLevel = selectedLevel;
                                  });
                                },
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Quick settings for goal of interaction
                        Text(localizations.goalOfInteraction, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // "Anything" option for goal
                            ChoiceChip(
                              label: Text('Anything', style: TextStyle(
                                fontSize: 12,
                                color: _anyGoal ? Colors.white : null,
                              )),
                              selected: _anyGoal,
                              backgroundColor: Colors.purple.withOpacity(0.2),
                              selectedColor: Colors.purple,
                              onSelected: (selected) async {
                                setState(() {
                                  _anyGoal = selected;
                                });
                              },
                            ),
                            ...questionProvider.goalOptions
                              .map((option) => ChoiceChip(
                                label: Text(getLocalizedOption(context, option), style: TextStyle(
                                  fontSize: 12,
                                  color: (!_anyGoal && _currentGoal == option) ? Colors.white : null,
                                )),
                                selected: !_anyGoal && _currentGoal == option,
                                onSelected: (_) async {
                                  await questionProvider.updateSettings(
                                    goalOfInteraction: [option],
                                  );
                                  setState(() {
                                    _currentGoal = option;
                                    _anyGoal = false;
                                  });
                                },
                              ))
                              .toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
              const SizedBox(height: 12),
              
              // Parameter chips above the question
              Wrap(
                spacing: 6,
                children: [
                  Chip(
                    label: Text(_anyMoodTone ? 'Anything' : getLocalizedOption(context, _currentMoodTone)),
                    avatar: const Icon(Icons.mood, size: 16),
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: _anyMoodTone ? Colors.purple.withOpacity(0.2) : null,
                  ),
                  Chip(
                    label: Text(_anyCategory ? 'Anything' : getLocalizedOption(context, _currentCategory)),
                    avatar: const Icon(Icons.category, size: 16),
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: _anyCategory ? Colors.purple.withOpacity(0.2) : null,
                  ),
                  Chip(
                    label: Text(getLocalizedOption(context, _currentComfortLevel)),
                    avatar: const Icon(Icons.safety_divider, size: 16),
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Chip(
                    label: Text(getLocalizedOption(context, questionProvider.context)),
                    avatar: const Icon(Icons.place, size: 16),
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Chip(
                    label: Text(_anyGoal ? 'Anything' : getLocalizedOption(context, _currentGoal)),
                    avatar: const Icon(Icons.flag, size: 16),
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    labelStyle: const TextStyle(fontSize: 12),
                    backgroundColor: _anyGoal ? Colors.purple.withOpacity(0.2) : null,
                  ),
                ],
              ),
                
              const SizedBox(height: 12),

              // Chat bubble with question or loading indicator
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
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
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
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
                        side: BorderSide(color: Colors.red),
                        backgroundColor: _lessLikeThis ? Colors.red.shade50 : Colors.transparent,
                      ),
                      child: Text(localizations.lessLikeThis, style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleMoreLikeThis,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.green),
                        backgroundColor: _moreLikeThis ? Colors.green.shade50 : Colors.transparent,
                      ),
                      child: Text(localizations.moreLikeThis, style: const TextStyle(color: Colors.green)),
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
              
              // Spacer to push the buttons to the bottom
              Expanded(
                child: Container(),
              ),
              
              // Preset buttons above the main action buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.lightbulb, size: 16),
                        label: Text(localizations.moodFunny),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _generateFunnyQuestion,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.psychology, size: 16),
                        label: Text(localizations.moodDeep),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _generateDeepQuestion,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.ac_unit, size: 16),
                        label: Text(localizations.goalBreakingIce),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _generateIcebreakerQuestion,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons at bottom
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    // Random question button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateRandomQuestion,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Random'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // New question with updated settings button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loadNewQuestion,
                        icon: const Icon(Icons.question_mark),
                        label: const Text('New Question'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
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

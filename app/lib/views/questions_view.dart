import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/question_provider.dart';

class QuestionsView extends StatefulWidget {
  final String questionText;

  const QuestionsView({super.key, this.questionText = "How was your day today?"});

  @override
  State<QuestionsView> createState() => _QuestionsViewState();
}

class _QuestionsViewState extends State<QuestionsView> {
  late String _currentQuestion;
  int _rating = 0;
  bool _isLoading = false;
  String? _error;
  
  // Feedback selections
  String? _relevance;
  String? _comfortLevel;
  String? _enjoyment;
  String? _depthAppropriateness;
  String? _intimacyAppropriateness;
  
  // Feedback options
  final List<String> _relevanceOptions = ['Very relevant', 'Somewhat relevant', 'Not relevant'];
  final List<String> _comfortOptions = ['Comfortable', 'Neutral', 'Uncomfortable'];
  final List<String> _enjoymentOptions = ['Enjoyable', 'Neutral', 'Not enjoyable'];
  final List<String> _depthOptions = ['Too deep', 'Just right', 'Too shallow'];
  final List<String> _intimacyOptions = ['Too intimate', 'Appropriate', 'Not intimate enough'];

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.questionText;
    
    // We need to use a post-frame callback for any provider access in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      // Initialize with the current question from provider if available
      if (questionProvider.currentQuestion != "How was your day today?") {
        setState(() {
          _currentQuestion = questionProvider.currentQuestion;
        });
      }
    });
  }

  void _loadNewQuestion() async {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    
    // First, save current question's feedback to history (if it's not the default question)
    if (_currentQuestion != widget.questionText) {
      await questionProvider.saveQuestionToHistory(
        rating: _rating,
        moreLikeThis: _moreLikeThis,
        lessLikeThis: _lessLikeThis,
        relevance: _relevance,
        comfortLevel: _comfortLevel,
        enjoyment: _enjoyment,
        depthAppropriateness: _depthAppropriateness,
        intimacyAppropriateness: _intimacyAppropriateness,
      );
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load new question from the question provider
      await questionProvider.generateQuestion();
      
      setState(() {
        _currentQuestion = questionProvider.currentQuestion;
        _rating = 0; // Reset rating for new question
        _moreLikeThis = false; // Reset button state
        _lessLikeThis = false; // Reset button state
        
        // Reset feedback selections
        _relevance = null;
        _comfortLevel = null;
        _enjoyment = null;
        _depthAppropriateness = null;
        _intimacyAppropriateness = null;
        
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
  
  bool _moreLikeThis = false;
  bool _lessLikeThis = false;

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
    
    // Save updated data to CSV
    _saveCurrentFeedback();
  }

  void _toggleMoreLikeThis() {
    setState(() {
      _moreLikeThis = true;
      _lessLikeThis = false;
    });
    
    // Save updated data to CSV
    _saveCurrentFeedback();
  }

  void _toggleLessLikeThis() {
    setState(() {
      _lessLikeThis = true;
      _moreLikeThis = false;
    });
    
    // Save updated data to CSV
    _saveCurrentFeedback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationship Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Manage Profiles',
            onPressed: () {
              Navigator.pushNamed(context, '/profiles');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
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
                        ? "Error loading question. Please try again."
                        : _currentQuestion,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
              ),
              const SizedBox(height: 20),

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
                      child: const Text("Less like this...", style: TextStyle(color: Colors.red)),
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
                      child: const Text("More like this...", style: TextStyle(color: Colors.green)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Star rating
              Column(
                children: [
                  const Text("Rate this question:"),
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
              
              const SizedBox(height: 20),
              
              // Structured feedback categories
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Relevance
                        _buildFeedbackCategory(
                          "Relevance", 
                          _relevanceOptions, 
                          _relevance, 
                          (value) {
                            setState(() => _relevance = value);
                            _saveCurrentFeedback();
                          }
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Comfort Level
                        _buildFeedbackCategory(
                          "Comfort Level", 
                          _comfortOptions, 
                          _comfortLevel, 
                          (value) {
                            setState(() => _comfortLevel = value);
                            _saveCurrentFeedback();
                          }
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Enjoyment
                        _buildFeedbackCategory(
                          "Enjoyment", 
                          _enjoymentOptions, 
                          _enjoyment, 
                          (value) {
                            setState(() => _enjoyment = value);
                            _saveCurrentFeedback();
                          }
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Depth Appropriateness
                        _buildFeedbackCategory(
                          "Depth Appropriateness", 
                          _depthOptions, 
                          _depthAppropriateness, 
                          (value) {
                            setState(() => _depthAppropriateness = value);
                            _saveCurrentFeedback();
                          }
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Intimacy Appropriateness
                        _buildFeedbackCategory(
                          "Intimacy Appropriateness", 
                          _intimacyOptions, 
                          _intimacyAppropriateness, 
                          (value) {
                            setState(() => _intimacyAppropriateness = value);
                            _saveCurrentFeedback();
                          }
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // New question button at bottom
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loadNewQuestion,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text("New question"),
                  ),
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
    // Skip if this is the default question
    if (_currentQuestion == widget.questionText) return;
    
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    questionProvider.saveQuestionToHistory(
      rating: _rating,
      moreLikeThis: _moreLikeThis,
      lessLikeThis: _lessLikeThis,
      relevance: _relevance,
      comfortLevel: _comfortLevel,
      enjoyment: _enjoyment,
      depthAppropriateness: _depthAppropriateness,
      intimacyAppropriateness: _intimacyAppropriateness,
    );
  }

// Helper widget to build feedback categories
  Widget _buildFeedbackCategory(
    String title, 
    List<String> options, 
    String? selectedValue, 
    Function(String) onSelected
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title, 
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(fontSize: 12),
              ),
              selected: isSelected,
              selectedColor: Colors.blue.shade100,
              backgroundColor: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (selected) {
                if (selected) {
                  onSelected(option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

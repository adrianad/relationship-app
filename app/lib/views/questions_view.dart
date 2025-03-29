import 'package:flutter/material.dart';

class QuestionsView extends StatefulWidget {
  final String questionText;

  const QuestionsView({super.key, this.questionText = "How was your day today?"});

  @override
  State<QuestionsView> createState() => _QuestionsViewState();
}

class _QuestionsViewState extends State<QuestionsView> {
  late String _currentQuestion;
  int _rating = 0;
  
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
  }

  void _loadNewQuestion() {
    setState(() {
      // In a real app, this would load from a question service
      _currentQuestion = "This is a new relationship question";
      _rating = 0; // Reset rating for new question
      _moreLikeThis = false; // Reset button state
      _lessLikeThis = false; // Reset button state
      
      // Reset feedback selections
      _relevance = null;
      _comfortLevel = null;
      _enjoyment = null;
      _depthAppropriateness = null;
      _intimacyAppropriateness = null;
    });
  }
  
  bool _moreLikeThis = false;
  bool _lessLikeThis = false;

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  void _toggleMoreLikeThis() {
    setState(() {
      _moreLikeThis = true;
      _lessLikeThis = false;
    });
  }

  void _toggleLessLikeThis() {
    setState(() {
      _lessLikeThis = true;
      _moreLikeThis = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationship Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
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
              // Chat bubble with question
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
                child: Text(_currentQuestion, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
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
                          (value) => setState(() => _relevance = value)
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Comfort Level
                        _buildFeedbackCategory(
                          "Comfort Level", 
                          _comfortOptions, 
                          _comfortLevel, 
                          (value) => setState(() => _comfortLevel = value)
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Enjoyment
                        _buildFeedbackCategory(
                          "Enjoyment", 
                          _enjoymentOptions, 
                          _enjoyment, 
                          (value) => setState(() => _enjoyment = value)
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Depth Appropriateness
                        _buildFeedbackCategory(
                          "Depth Appropriateness", 
                          _depthOptions, 
                          _depthAppropriateness, 
                          (value) => setState(() => _depthAppropriateness = value)
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Intimacy Appropriateness
                        _buildFeedbackCategory(
                          "Intimacy Appropriateness", 
                          _intimacyOptions, 
                          _intimacyAppropriateness, 
                          (value) => setState(() => _intimacyAppropriateness = value)
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

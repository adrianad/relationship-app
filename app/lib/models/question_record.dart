class QuestionRecord {
  final int? id;
  final int profileId;
  final String question;
  final int rating;
  final bool moreLikeThis;
  final bool lessLikeThis;
  final String? relevance;
  final String? comfortLevel;
  final String? enjoyment;
  final String? depthAppropriateness;
  final String? intimacyAppropriateness;
  
  // Settings used to generate this question
  final String depthOfRelationship;
  final String moodTone;
  final String context;
  final String comfortLevelSetting;
  final String goalOfInteraction;
  final String thematicCategory;
  final DateTime timestamp;

  QuestionRecord({
    this.id,
    required this.profileId,
    required this.question,
    required this.rating,
    this.moreLikeThis = false,
    this.lessLikeThis = false,
    this.relevance,
    this.comfortLevel,
    this.enjoyment,
    this.depthAppropriateness,
    this.intimacyAppropriateness,
    required this.depthOfRelationship,
    required this.moodTone,
    required this.context,
    required this.comfortLevelSetting,
    required this.goalOfInteraction,
    required this.thematicCategory,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'question': question,
      'rating': rating,
      'more_like_this': moreLikeThis ? 1 : 0,
      'less_like_this': lessLikeThis ? 1 : 0,
      'relevance': relevance,
      'comfort_level': comfortLevel,
      'enjoyment': enjoyment,
      'depth_appropriateness': depthAppropriateness,
      'intimacy_appropriateness': intimacyAppropriateness,
      'depth_of_relationship': depthOfRelationship,
      'mood_tone': moodTone,
      'context': context,
      'comfort_level_setting': comfortLevelSetting,
      'goal_of_interaction': goalOfInteraction,
      'thematic_category': thematicCategory,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create QuestionRecord from Map
  factory QuestionRecord.fromMap(Map<String, dynamic> map) {
    return QuestionRecord(
      id: map['id'],
      profileId: map['profile_id'],
      question: map['question'],
      rating: map['rating'],
      moreLikeThis: map['more_like_this'] == 1,
      lessLikeThis: map['less_like_this'] == 1,
      relevance: map['relevance'],
      comfortLevel: map['comfort_level'],
      enjoyment: map['enjoyment'],
      depthAppropriateness: map['depth_appropriateness'],
      intimacyAppropriateness: map['intimacy_appropriateness'],
      depthOfRelationship: map['depth_of_relationship'],
      moodTone: map['mood_tone'],
      context: map['context'],
      comfortLevelSetting: map['comfort_level_setting'],
      goalOfInteraction: map['goal_of_interaction'],
      thematicCategory: map['thematic_category'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  // Create a copy with updated fields
  QuestionRecord copyWith({
    int? id,
    int? profileId,
    String? question,
    int? rating,
    bool? moreLikeThis,
    bool? lessLikeThis,
    String? relevance,
    String? comfortLevel,
    String? enjoyment,
    String? depthAppropriateness,
    String? intimacyAppropriateness,
    String? depthOfRelationship,
    String? moodTone,
    String? context,
    String? comfortLevelSetting,
    String? goalOfInteraction,
    String? thematicCategory,
    DateTime? timestamp,
  }) {
    return QuestionRecord(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      question: question ?? this.question,
      rating: rating ?? this.rating,
      moreLikeThis: moreLikeThis ?? this.moreLikeThis,
      lessLikeThis: lessLikeThis ?? this.lessLikeThis,
      relevance: relevance ?? this.relevance,
      comfortLevel: comfortLevel ?? this.comfortLevel,
      enjoyment: enjoyment ?? this.enjoyment,
      depthAppropriateness: depthAppropriateness ?? this.depthAppropriateness,
      intimacyAppropriateness: intimacyAppropriateness ?? this.intimacyAppropriateness,
      depthOfRelationship: depthOfRelationship ?? this.depthOfRelationship,
      moodTone: moodTone ?? this.moodTone,
      context: context ?? this.context,
      comfortLevelSetting: comfortLevelSetting ?? this.comfortLevelSetting,
      goalOfInteraction: goalOfInteraction ?? this.goalOfInteraction,
      thematicCategory: thematicCategory ?? this.thematicCategory,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Create formatted history entry for LLM prompt
  String toPromptEntry(int index) {
    // Build detailed feedback section
    String feedbackSection = '';
    
    // Format main feedback indicators
    if (moreLikeThis) {
      feedbackSection += "👍 User wants MORE questions like this. ";
    }
    if (lessLikeThis) {
      feedbackSection += "👎 User wants FEWER questions like this. ";
    }
    
    // Format categorical feedback with clear labels
    List<String> detailedFeedback = [];
    if (relevance != null) detailedFeedback.add("Relevance: $relevance");
    if (comfortLevel != null) detailedFeedback.add("Comfort Level: $comfortLevel");
    if (enjoyment != null) detailedFeedback.add("Enjoyment: $enjoyment");
    if (depthAppropriateness != null) detailedFeedback.add("Depth Appropriateness: $depthAppropriateness");
    if (intimacyAppropriateness != null) detailedFeedback.add("Intimacy Appropriateness: $intimacyAppropriateness");
    
    // Add detailed feedback if any was provided
    if (detailedFeedback.isNotEmpty) {
      feedbackSection += "\n      Detailed feedback: " + detailedFeedback.join("; ");
    }
    
    return '''
$index. "$question"
   - Depth of Relationship: $depthOfRelationship
   - Mood/Tone: $moodTone
   - Context: $context
   - Comfort Level: $comfortLevelSetting
   - Goal of Interaction: $goalOfInteraction
   - Thematic Category: $thematicCategory
   - User Rating: $rating/5
   - User Feedback: ${feedbackSection.isEmpty ? 'None provided' : feedbackSection}
''';
  }
}
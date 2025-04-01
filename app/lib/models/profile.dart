class Profile {
  final int? id;
  final String name;
  final String description;
  final bool isActive;
  
  // Settings
  final String depthOfRelationship;
  final List<String> moodTone;
  final String context;
  final String comfortLevel;
  final List<String> goalOfInteraction;
  final List<String> thematicCategory;
  final String llmProvider;
  
  // Random settings preferences
  final bool anyMoodTone;
  final bool anyCategory;
  final bool anyGoal;
  final String? lastRandomMoodTone;
  final String? lastRandomCategory;
  final String? lastRandomGoal;

  Profile({
    this.id,
    required this.name,
    this.description = '',
    this.isActive = false,
    required this.depthOfRelationship,
    required this.moodTone,
    required this.context,
    required this.comfortLevel,
    required this.goalOfInteraction,
    required this.thematicCategory,
    required this.llmProvider,
    this.anyMoodTone = false,
    this.anyCategory = false,
    this.anyGoal = false,
    this.lastRandomMoodTone,
    this.lastRandomCategory,
    this.lastRandomGoal,
  });

  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'depth_of_relationship': depthOfRelationship,
      'mood_tone': moodTone.join(','),
      'context': context,
      'comfort_level': comfortLevel,
      'goal_of_interaction': goalOfInteraction.join(','),
      'thematic_category': thematicCategory.join(','),
      'llm_provider': llmProvider,
      'any_mood_tone': anyMoodTone ? 1 : 0,
      'any_category': anyCategory ? 1 : 0,
      'any_goal': anyGoal ? 1 : 0,
      'last_random_mood_tone': lastRandomMoodTone,
      'last_random_category': lastRandomCategory,
      'last_random_goal': lastRandomGoal,
    };
  }

  // Create Profile from Map
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      isActive: map['is_active'] == 1,
      depthOfRelationship: map['depth_of_relationship'],
      moodTone: (map['mood_tone'] as String).split(','),
      context: map['context'],
      comfortLevel: map['comfort_level'],
      goalOfInteraction: (map['goal_of_interaction'] as String).split(','),
      thematicCategory: (map['thematic_category'] as String).split(','),
      llmProvider: map['llm_provider'],
      anyMoodTone: map['any_mood_tone'] == 1,
      anyCategory: map['any_category'] == 1,
      anyGoal: map['any_goal'] == 1,
      lastRandomMoodTone: map['last_random_mood_tone'],
      lastRandomCategory: map['last_random_category'],
      lastRandomGoal: map['last_random_goal'],
    );
  }

  // Create a copy with updated fields
  Profile copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
    String? depthOfRelationship,
    List<String>? moodTone,
    String? context,
    String? comfortLevel,
    List<String>? goalOfInteraction,
    List<String>? thematicCategory,
    String? llmProvider,
    bool? anyMoodTone,
    bool? anyCategory,
    bool? anyGoal,
    String? lastRandomMoodTone,
    String? lastRandomCategory,
    String? lastRandomGoal,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      depthOfRelationship: depthOfRelationship ?? this.depthOfRelationship,
      moodTone: moodTone ?? this.moodTone,
      context: context ?? this.context,
      comfortLevel: comfortLevel ?? this.comfortLevel,
      goalOfInteraction: goalOfInteraction ?? this.goalOfInteraction,
      thematicCategory: thematicCategory ?? this.thematicCategory,
      llmProvider: llmProvider ?? this.llmProvider,
      anyMoodTone: anyMoodTone ?? this.anyMoodTone,
      anyCategory: anyCategory ?? this.anyCategory,
      anyGoal: anyGoal ?? this.anyGoal,
      lastRandomMoodTone: lastRandomMoodTone ?? this.lastRandomMoodTone,
      lastRandomCategory: lastRandomCategory ?? this.lastRandomCategory,
      lastRandomGoal: lastRandomGoal ?? this.lastRandomGoal,
    );
  }

  // Default profile
  static Profile defaultProfile() {
    return Profile(
      name: 'Default Profile',
      description: 'Default settings for question generation',
      isActive: true,
      depthOfRelationship: 'Friends',
      moodTone: ['Funny/Playful'],
      context: 'Casual hangout',
      comfortLevel: 'Moderate',
      goalOfInteraction: ['Getting to know each other better'],
      thematicCategory: ['Past experiences'],
      llmProvider: 'OpenAI',
      anyMoodTone: false,
      anyCategory: false,
      anyGoal: false,
      lastRandomMoodTone: null,
      lastRandomCategory: null,
      lastRandomGoal: null,
    );
  }
}
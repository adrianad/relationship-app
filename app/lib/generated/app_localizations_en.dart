// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Relationship App';

  @override
  String get relationshipQuestions => 'Relationship Questions';

  @override
  String get manageProfiles => 'Manage Profiles';

  @override
  String get settings => 'Settings';

  @override
  String settingsFor(String name) {
    return 'Settings for $name';
  }

  @override
  String get noActiveProfile => 'No active profile found. Please create a profile first.';

  @override
  String get rateThisQuestion => 'Rate this question:';

  @override
  String get newQuestion => 'New question';

  @override
  String get moreLikeThis => 'More like this...';

  @override
  String get lessLikeThis => 'Less like this...';

  @override
  String get errorLoadingQuestion => 'Error loading question. Please try again.';

  @override
  String get relevance => 'Relevance';

  @override
  String get comfortLevel => 'Comfort Level';

  @override
  String get enjoyment => 'Enjoyment';

  @override
  String get depthAppropriateness => 'Depth Appropriateness';

  @override
  String get intimacyAppropriateness => 'Intimacy Appropriateness';

  @override
  String get veryRelevant => 'Very relevant';

  @override
  String get somewhatRelevant => 'Somewhat relevant';

  @override
  String get notRelevant => 'Not relevant';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get neutral => 'Neutral';

  @override
  String get uncomfortable => 'Uncomfortable';

  @override
  String get enjoyable => 'Enjoyable';

  @override
  String get notEnjoyable => 'Not enjoyable';

  @override
  String get tooDeep => 'Too deep';

  @override
  String get justRight => 'Just right';

  @override
  String get tooShallow => 'Too shallow';

  @override
  String get tooIntimate => 'Too intimate';

  @override
  String get appropriate => 'Appropriate';

  @override
  String get notIntimateEnough => 'Not intimate enough';

  @override
  String get questionGenerationSettings => 'Question Generation Settings';

  @override
  String get llmProvider => 'LLM Provider';

  @override
  String get selectAiProviderHint => 'Select which AI provider to use for generating questions';

  @override
  String get depthOfRelationship => 'Depth of Relationship';

  @override
  String get howWellPeopleKnowEachOther => 'How well do the people know each other?';

  @override
  String get moodTone => 'Mood/Tone';

  @override
  String get selectTonesForQuestions => 'Select one or more desired tones for the questions';

  @override
  String get context => 'Context';

  @override
  String get settingForConversation => 'In what setting will this conversation take place?';

  @override
  String get howChallengingQuestionsBecome => 'How challenging or personal should the questions be?';

  @override
  String get goalOfInteraction => 'Goal of Interaction';

  @override
  String get whatQuestionsAccomplish => 'What should these questions help accomplish?';

  @override
  String get thematicCategory => 'Thematic Category';

  @override
  String get topicsQuestionsShoulCover => 'What kinds of topics should the questions cover?';

  @override
  String get applySettings => 'Apply Settings';

  @override
  String get settingsUpdatedSuccessfully => 'Settings updated successfully';

  @override
  String get conversationProfiles => 'Conversation Profiles';

  @override
  String get noProfilesYet => 'No profiles yet. Create your first profile!';

  @override
  String get configureSettings => 'Configure settings';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String get createNewProfile => 'Create New Profile';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get profileName => 'Profile Name';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get noteAdditionalSettings => 'Note: Additional settings can be configured in the Settings screen.';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get save => 'Save';

  @override
  String deleteProfileConfirmation(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get german => 'German';

  @override
  String get openAiProvider => 'OpenAI';

  @override
  String get anthropicProvider => 'Anthropic';

  @override
  String get geminiProvider => 'Gemini';

  @override
  String get depthAcquaintances => 'Acquaintances';

  @override
  String get depthFriends => 'Friends';

  @override
  String get depthCloseFriends => 'Close Friends';

  @override
  String get depthPartners => 'Partners/Lovers';

  @override
  String get moodFunny => 'Funny/Playful';

  @override
  String get moodSerious => 'Serious/Thoughtful';

  @override
  String get moodDeep => 'Deep/Reflective';

  @override
  String get moodSensual => 'Sensual/Intimate';

  @override
  String get moodCrazy => 'Crazy/Absurd';

  @override
  String get moodProvocative => 'Provocative/Dirty';

  @override
  String get contextCasual => 'Casual hangout';

  @override
  String get contextDate => 'Date night';

  @override
  String get contextOnline => 'Online chat';

  @override
  String get contextParty => 'Party setting';

  @override
  String get contextPrivate => 'Private/intimate setting';

  @override
  String get contextRoadTrip => 'Road trip';

  @override
  String get contextDinner => 'Dinner conversation';

  @override
  String get comfortSafe => 'Safe (low risk)';

  @override
  String get comfortModerate => 'Moderate';

  @override
  String get comfortHighRisk => 'High Risk';

  @override
  String get goalGettingToKnow => 'Getting to know each other better';

  @override
  String get goalDeepening => 'Deepening intimacy';

  @override
  String get goalBreakingIce => 'Breaking the ice';

  @override
  String get goalThoughtful => 'Stimulating thoughtful discussion';

  @override
  String get goalHumor => 'Provoking humor/playfulness';

  @override
  String get goalFantasies => 'Exploring fantasies/desires';

  @override
  String get categoryPast => 'Past experiences';

  @override
  String get categoryValues => 'Personal values/beliefs';

  @override
  String get categoryHypothetical => 'Hypothetical scenarios';

  @override
  String get categoryDreams => 'Dreams/goals/ambitions';

  @override
  String get categoryPreferences => 'Preferences';

  @override
  String get categoryRelationships => 'Relationships/intimacy';

  @override
  String get categorySecrets => 'Secrets/confessions';

  @override
  String get shareQuestion => 'Share this question';

  @override
  String get questionOfTheDay => 'Question of the Day';

  @override
  String get enableDailyNotification => 'Enable Daily Question';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String get dailyQuestionEnabled => 'Daily question notification enabled';

  @override
  String get dailyQuestionDisabled => 'Daily question notification disabled';
}

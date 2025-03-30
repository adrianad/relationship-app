import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Relationship App'**
  String get appTitle;

  /// No description provided for @relationshipQuestions.
  ///
  /// In en, this message translates to:
  /// **'Relationship Questions'**
  String get relationshipQuestions;

  /// No description provided for @manageProfiles.
  ///
  /// In en, this message translates to:
  /// **'Manage Profiles'**
  String get manageProfiles;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsFor.
  ///
  /// In en, this message translates to:
  /// **'Settings for {name}'**
  String settingsFor(String name);

  /// No description provided for @noActiveProfile.
  ///
  /// In en, this message translates to:
  /// **'No active profile found. Please create a profile first.'**
  String get noActiveProfile;

  /// No description provided for @rateThisQuestion.
  ///
  /// In en, this message translates to:
  /// **'Rate this question:'**
  String get rateThisQuestion;

  /// No description provided for @newQuestion.
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get newQuestion;

  /// No description provided for @moreLikeThis.
  ///
  /// In en, this message translates to:
  /// **'More like this...'**
  String get moreLikeThis;

  /// No description provided for @lessLikeThis.
  ///
  /// In en, this message translates to:
  /// **'Less like this...'**
  String get lessLikeThis;

  /// No description provided for @errorLoadingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Error loading question. Please try again.'**
  String get errorLoadingQuestion;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// No description provided for @comfortLevel.
  ///
  /// In en, this message translates to:
  /// **'Comfort Level'**
  String get comfortLevel;

  /// No description provided for @enjoyment.
  ///
  /// In en, this message translates to:
  /// **'Enjoyment'**
  String get enjoyment;

  /// No description provided for @depthAppropriateness.
  ///
  /// In en, this message translates to:
  /// **'Depth Appropriateness'**
  String get depthAppropriateness;

  /// No description provided for @intimacyAppropriateness.
  ///
  /// In en, this message translates to:
  /// **'Intimacy Appropriateness'**
  String get intimacyAppropriateness;

  /// No description provided for @veryRelevant.
  ///
  /// In en, this message translates to:
  /// **'Very relevant'**
  String get veryRelevant;

  /// No description provided for @somewhatRelevant.
  ///
  /// In en, this message translates to:
  /// **'Somewhat relevant'**
  String get somewhatRelevant;

  /// No description provided for @notRelevant.
  ///
  /// In en, this message translates to:
  /// **'Not relevant'**
  String get notRelevant;

  /// No description provided for @comfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get comfortable;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @uncomfortable.
  ///
  /// In en, this message translates to:
  /// **'Uncomfortable'**
  String get uncomfortable;

  /// No description provided for @enjoyable.
  ///
  /// In en, this message translates to:
  /// **'Enjoyable'**
  String get enjoyable;

  /// No description provided for @notEnjoyable.
  ///
  /// In en, this message translates to:
  /// **'Not enjoyable'**
  String get notEnjoyable;

  /// No description provided for @tooDeep.
  ///
  /// In en, this message translates to:
  /// **'Too deep'**
  String get tooDeep;

  /// No description provided for @justRight.
  ///
  /// In en, this message translates to:
  /// **'Just right'**
  String get justRight;

  /// No description provided for @tooShallow.
  ///
  /// In en, this message translates to:
  /// **'Too shallow'**
  String get tooShallow;

  /// No description provided for @tooIntimate.
  ///
  /// In en, this message translates to:
  /// **'Too intimate'**
  String get tooIntimate;

  /// No description provided for @appropriate.
  ///
  /// In en, this message translates to:
  /// **'Appropriate'**
  String get appropriate;

  /// No description provided for @notIntimateEnough.
  ///
  /// In en, this message translates to:
  /// **'Not intimate enough'**
  String get notIntimateEnough;

  /// No description provided for @questionGenerationSettings.
  ///
  /// In en, this message translates to:
  /// **'Question Generation Settings'**
  String get questionGenerationSettings;

  /// No description provided for @llmProvider.
  ///
  /// In en, this message translates to:
  /// **'LLM Provider'**
  String get llmProvider;

  /// No description provided for @selectAiProviderHint.
  ///
  /// In en, this message translates to:
  /// **'Select which AI provider to use for generating questions'**
  String get selectAiProviderHint;

  /// No description provided for @depthOfRelationship.
  ///
  /// In en, this message translates to:
  /// **'Depth of Relationship'**
  String get depthOfRelationship;

  /// No description provided for @howWellPeopleKnowEachOther.
  ///
  /// In en, this message translates to:
  /// **'How well do the people know each other?'**
  String get howWellPeopleKnowEachOther;

  /// No description provided for @moodTone.
  ///
  /// In en, this message translates to:
  /// **'Mood/Tone'**
  String get moodTone;

  /// No description provided for @selectTonesForQuestions.
  ///
  /// In en, this message translates to:
  /// **'Select one or more desired tones for the questions'**
  String get selectTonesForQuestions;

  /// No description provided for @context.
  ///
  /// In en, this message translates to:
  /// **'Context'**
  String get context;

  /// No description provided for @settingForConversation.
  ///
  /// In en, this message translates to:
  /// **'In what setting will this conversation take place?'**
  String get settingForConversation;

  /// No description provided for @howChallengingQuestionsBecome.
  ///
  /// In en, this message translates to:
  /// **'How challenging or personal should the questions be?'**
  String get howChallengingQuestionsBecome;

  /// No description provided for @goalOfInteraction.
  ///
  /// In en, this message translates to:
  /// **'Goal of Interaction'**
  String get goalOfInteraction;

  /// No description provided for @whatQuestionsAccomplish.
  ///
  /// In en, this message translates to:
  /// **'What should these questions help accomplish?'**
  String get whatQuestionsAccomplish;

  /// No description provided for @thematicCategory.
  ///
  /// In en, this message translates to:
  /// **'Thematic Category'**
  String get thematicCategory;

  /// No description provided for @topicsQuestionsShoulCover.
  ///
  /// In en, this message translates to:
  /// **'What kinds of topics should the questions cover?'**
  String get topicsQuestionsShoulCover;

  /// No description provided for @applySettings.
  ///
  /// In en, this message translates to:
  /// **'Apply Settings'**
  String get applySettings;

  /// No description provided for @settingsUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get settingsUpdatedSuccessfully;

  /// No description provided for @conversationProfiles.
  ///
  /// In en, this message translates to:
  /// **'Conversation Profiles'**
  String get conversationProfiles;

  /// No description provided for @noProfilesYet.
  ///
  /// In en, this message translates to:
  /// **'No profiles yet. Create your first profile!'**
  String get noProfilesYet;

  /// No description provided for @configureSettings.
  ///
  /// In en, this message translates to:
  /// **'Configure settings'**
  String get configureSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get deleteProfile;

  /// No description provided for @createNewProfile.
  ///
  /// In en, this message translates to:
  /// **'Create New Profile'**
  String get createNewProfile;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get profileName;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @noteAdditionalSettings.
  ///
  /// In en, this message translates to:
  /// **'Note: Additional settings can be configured in the Settings screen.'**
  String get noteAdditionalSettings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteProfileConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteProfileConfirmation(String name);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @openAiProvider.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get openAiProvider;

  /// No description provided for @anthropicProvider.
  ///
  /// In en, this message translates to:
  /// **'Anthropic'**
  String get anthropicProvider;

  /// No description provided for @geminiProvider.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get geminiProvider;

  /// No description provided for @depthAcquaintances.
  ///
  /// In en, this message translates to:
  /// **'Acquaintances'**
  String get depthAcquaintances;

  /// No description provided for @depthFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get depthFriends;

  /// No description provided for @depthCloseFriends.
  ///
  /// In en, this message translates to:
  /// **'Close Friends'**
  String get depthCloseFriends;

  /// No description provided for @depthPartners.
  ///
  /// In en, this message translates to:
  /// **'Partners/Lovers'**
  String get depthPartners;

  /// No description provided for @moodFunny.
  ///
  /// In en, this message translates to:
  /// **'Funny/Playful'**
  String get moodFunny;

  /// No description provided for @moodSerious.
  ///
  /// In en, this message translates to:
  /// **'Serious/Thoughtful'**
  String get moodSerious;

  /// No description provided for @moodDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep/Reflective'**
  String get moodDeep;

  /// No description provided for @moodSensual.
  ///
  /// In en, this message translates to:
  /// **'Sensual/Intimate'**
  String get moodSensual;

  /// No description provided for @moodCrazy.
  ///
  /// In en, this message translates to:
  /// **'Crazy/Absurd'**
  String get moodCrazy;

  /// No description provided for @moodProvocative.
  ///
  /// In en, this message translates to:
  /// **'Provocative/Dirty'**
  String get moodProvocative;

  /// No description provided for @contextCasual.
  ///
  /// In en, this message translates to:
  /// **'Casual hangout'**
  String get contextCasual;

  /// No description provided for @contextDate.
  ///
  /// In en, this message translates to:
  /// **'Date night'**
  String get contextDate;

  /// No description provided for @contextOnline.
  ///
  /// In en, this message translates to:
  /// **'Online chat'**
  String get contextOnline;

  /// No description provided for @contextParty.
  ///
  /// In en, this message translates to:
  /// **'Party setting'**
  String get contextParty;

  /// No description provided for @contextPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private/intimate setting'**
  String get contextPrivate;

  /// No description provided for @contextRoadTrip.
  ///
  /// In en, this message translates to:
  /// **'Road trip'**
  String get contextRoadTrip;

  /// No description provided for @contextDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner conversation'**
  String get contextDinner;

  /// No description provided for @comfortSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe (low risk)'**
  String get comfortSafe;

  /// No description provided for @comfortModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get comfortModerate;

  /// No description provided for @comfortHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get comfortHighRisk;

  /// No description provided for @goalGettingToKnow.
  ///
  /// In en, this message translates to:
  /// **'Getting to know each other better'**
  String get goalGettingToKnow;

  /// No description provided for @goalDeepening.
  ///
  /// In en, this message translates to:
  /// **'Deepening intimacy'**
  String get goalDeepening;

  /// No description provided for @goalBreakingIce.
  ///
  /// In en, this message translates to:
  /// **'Breaking the ice'**
  String get goalBreakingIce;

  /// No description provided for @goalThoughtful.
  ///
  /// In en, this message translates to:
  /// **'Stimulating thoughtful discussion'**
  String get goalThoughtful;

  /// No description provided for @goalHumor.
  ///
  /// In en, this message translates to:
  /// **'Provoking humor/playfulness'**
  String get goalHumor;

  /// No description provided for @goalFantasies.
  ///
  /// In en, this message translates to:
  /// **'Exploring fantasies/desires'**
  String get goalFantasies;

  /// No description provided for @categoryPast.
  ///
  /// In en, this message translates to:
  /// **'Past experiences'**
  String get categoryPast;

  /// No description provided for @categoryValues.
  ///
  /// In en, this message translates to:
  /// **'Personal values/beliefs'**
  String get categoryValues;

  /// No description provided for @categoryHypothetical.
  ///
  /// In en, this message translates to:
  /// **'Hypothetical scenarios'**
  String get categoryHypothetical;

  /// No description provided for @categoryDreams.
  ///
  /// In en, this message translates to:
  /// **'Dreams/goals/ambitions'**
  String get categoryDreams;

  /// No description provided for @categoryPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get categoryPreferences;

  /// No description provided for @categoryRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships/intimacy'**
  String get categoryRelationships;

  /// No description provided for @categorySecrets.
  ///
  /// In en, this message translates to:
  /// **'Secrets/confessions'**
  String get categorySecrets;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

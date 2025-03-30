// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Beziehungs-App';

  @override
  String get relationshipQuestions => 'Beziehungsfragen';

  @override
  String get manageProfiles => 'Profile verwalten';

  @override
  String get settings => 'Einstellungen';

  @override
  String settingsFor(String name) {
    return 'Einstellungen für $name';
  }

  @override
  String get noActiveProfile => 'Kein aktives Profil gefunden. Bitte erstelle zuerst ein Profil.';

  @override
  String get rateThisQuestion => 'Bewerte diese Frage:';

  @override
  String get newQuestion => 'Neue Frage';

  @override
  String get moreLikeThis => 'Mehr wie diese...';

  @override
  String get lessLikeThis => 'Weniger wie diese...';

  @override
  String get errorLoadingQuestion => 'Fehler beim Laden der Frage. Bitte versuche es erneut.';

  @override
  String get relevance => 'Relevanz';

  @override
  String get comfortLevel => 'Komfortlevel';

  @override
  String get enjoyment => 'Vergnügen';

  @override
  String get depthAppropriateness => 'Angemessenheit der Tiefe';

  @override
  String get intimacyAppropriateness => 'Angemessenheit der Intimität';

  @override
  String get veryRelevant => 'Sehr relevant';

  @override
  String get somewhatRelevant => 'Etwas relevant';

  @override
  String get notRelevant => 'Nicht relevant';

  @override
  String get comfortable => 'Angenehm';

  @override
  String get neutral => 'Neutral';

  @override
  String get uncomfortable => 'Unangenehm';

  @override
  String get enjoyable => 'Unterhaltsam';

  @override
  String get notEnjoyable => 'Nicht unterhaltsam';

  @override
  String get tooDeep => 'Zu tief';

  @override
  String get justRight => 'Genau richtig';

  @override
  String get tooShallow => 'Zu oberflächlich';

  @override
  String get tooIntimate => 'Zu intim';

  @override
  String get appropriate => 'Angemessen';

  @override
  String get notIntimateEnough => 'Nicht intim genug';

  @override
  String get questionGenerationSettings => 'Einstellungen zur Fragengenerierung';

  @override
  String get llmProvider => 'LLM-Anbieter';

  @override
  String get selectAiProviderHint => 'Wähle, welcher KI-Anbieter für die Generierung von Fragen verwendet werden soll';

  @override
  String get depthOfRelationship => 'Tiefe der Beziehung';

  @override
  String get howWellPeopleKnowEachOther => 'Wie gut kennen sich die Personen?';

  @override
  String get moodTone => 'Stimmung/Tonfall';

  @override
  String get selectTonesForQuestions => 'Wähle einen oder mehrere gewünschte Tonfälle für die Fragen';

  @override
  String get context => 'Kontext';

  @override
  String get settingForConversation => 'In welchem Umfeld wird dieses Gespräch stattfinden?';

  @override
  String get howChallengingQuestionsBecome => 'Wie herausfordernd oder persönlich sollten die Fragen sein?';

  @override
  String get goalOfInteraction => 'Ziel der Interaktion';

  @override
  String get whatQuestionsAccomplish => 'Was sollen diese Fragen helfen zu erreichen?';

  @override
  String get thematicCategory => 'Thematische Kategorie';

  @override
  String get topicsQuestionsShoulCover => 'Welche Arten von Themen sollten die Fragen abdecken?';

  @override
  String get applySettings => 'Einstellungen anwenden';

  @override
  String get settingsUpdatedSuccessfully => 'Einstellungen erfolgreich aktualisiert';

  @override
  String get conversationProfiles => 'Gesprächsprofile';

  @override
  String get noProfilesYet => 'Noch keine Profile. Erstelle dein erstes Profil!';

  @override
  String get configureSettings => 'Einstellungen konfigurieren';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get deleteProfile => 'Profil löschen';

  @override
  String get createNewProfile => 'Neues Profil erstellen';

  @override
  String get editProfileTitle => 'Profil bearbeiten';

  @override
  String get profileName => 'Profilname';

  @override
  String get descriptionOptional => 'Beschreibung (optional)';

  @override
  String get pleaseEnterName => 'Bitte gib einen Namen ein';

  @override
  String get noteAdditionalSettings => 'Hinweis: Zusätzliche Einstellungen können im Einstellungsbildschirm konfiguriert werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get create => 'Erstellen';

  @override
  String get save => 'Speichern';

  @override
  String deleteProfileConfirmation(String name) {
    return 'Bist du sicher, dass du \"$name\" löschen möchtest? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get french => 'Französisch';

  @override
  String get german => 'Deutsch';

  @override
  String get openAiProvider => 'OpenAI';

  @override
  String get anthropicProvider => 'Anthropic';

  @override
  String get geminiProvider => 'Gemini';

  @override
  String get depthAcquaintances => 'Bekannte';

  @override
  String get depthFriends => 'Freunde';

  @override
  String get depthCloseFriends => 'Enge Freunde';

  @override
  String get depthPartners => 'Partner/Liebhaber';

  @override
  String get moodFunny => 'Lustig/Verspielt';

  @override
  String get moodSerious => 'Ernst/Nachdenklich';

  @override
  String get moodDeep => 'Tief/Reflektierend';

  @override
  String get moodSensual => 'Sinnlich/Intim';

  @override
  String get moodCrazy => 'Verrückt/Absurd';

  @override
  String get moodProvocative => 'Provokativ/Anzüglich';

  @override
  String get contextCasual => 'Lockeres Treffen';

  @override
  String get contextDate => 'Date-Abend';

  @override
  String get contextOnline => 'Online-Chat';

  @override
  String get contextParty => 'Party-Umgebung';

  @override
  String get contextPrivate => 'Private/intime Umgebung';

  @override
  String get contextRoadTrip => 'Roadtrip';

  @override
  String get contextDinner => 'Abendessen-Gespräch';

  @override
  String get comfortSafe => 'Sicher (geringes Risiko)';

  @override
  String get comfortModerate => 'Moderat';

  @override
  String get comfortHighRisk => 'Hohes Risiko';

  @override
  String get goalGettingToKnow => 'Einander besser kennenlernen';

  @override
  String get goalDeepening => 'Intimität vertiefen';

  @override
  String get goalBreakingIce => 'Das Eis brechen';

  @override
  String get goalThoughtful => 'Nachdenkliche Diskussion anregen';

  @override
  String get goalHumor => 'Humor/Verspieltheit fördern';

  @override
  String get goalFantasies => 'Fantasien/Wünsche erkunden';

  @override
  String get categoryPast => 'Vergangene Erfahrungen';

  @override
  String get categoryValues => 'Persönliche Werte/Überzeugungen';

  @override
  String get categoryHypothetical => 'Hypothetische Szenarien';

  @override
  String get categoryDreams => 'Träume/Ziele/Ambitionen';

  @override
  String get categoryPreferences => 'Vorlieben';

  @override
  String get categoryRelationships => 'Beziehungen/Intimität';

  @override
  String get categorySecrets => 'Geheimnisse/Geständnisse';
}

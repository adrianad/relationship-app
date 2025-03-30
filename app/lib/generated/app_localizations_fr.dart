// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'App de Relation';

  @override
  String get relationshipQuestions => 'Questions de Relation';

  @override
  String get manageProfiles => 'Gérer les Profils';

  @override
  String get settings => 'Paramètres';

  @override
  String settingsFor(String name) {
    return 'Paramètres pour $name';
  }

  @override
  String get noActiveProfile => 'Aucun profil actif trouvé. Veuillez d\'abord créer un profil.';

  @override
  String get rateThisQuestion => 'Évaluez cette question:';

  @override
  String get newQuestion => 'Nouvelle question';

  @override
  String get moreLikeThis => 'Plus comme celle-ci...';

  @override
  String get lessLikeThis => 'Moins comme celle-ci...';

  @override
  String get errorLoadingQuestion => 'Erreur lors du chargement de la question. Veuillez réessayer.';

  @override
  String get relevance => 'Pertinence';

  @override
  String get comfortLevel => 'Niveau de Confort';

  @override
  String get enjoyment => 'Plaisir';

  @override
  String get depthAppropriateness => 'Pertinence de la Profondeur';

  @override
  String get intimacyAppropriateness => 'Pertinence de l\'Intimité';

  @override
  String get veryRelevant => 'Très pertinent';

  @override
  String get somewhatRelevant => 'Assez pertinent';

  @override
  String get notRelevant => 'Pas pertinent';

  @override
  String get comfortable => 'Confortable';

  @override
  String get neutral => 'Neutre';

  @override
  String get uncomfortable => 'Inconfortable';

  @override
  String get enjoyable => 'Agréable';

  @override
  String get notEnjoyable => 'Pas agréable';

  @override
  String get tooDeep => 'Trop profond';

  @override
  String get justRight => 'Juste bien';

  @override
  String get tooShallow => 'Trop superficiel';

  @override
  String get tooIntimate => 'Trop intime';

  @override
  String get appropriate => 'Approprié';

  @override
  String get notIntimateEnough => 'Pas assez intime';

  @override
  String get questionGenerationSettings => 'Paramètres de Génération de Questions';

  @override
  String get llmProvider => 'Fournisseur de LLM';

  @override
  String get selectAiProviderHint => 'Sélectionnez quel fournisseur d\'IA utiliser pour générer des questions';

  @override
  String get depthOfRelationship => 'Profondeur de la Relation';

  @override
  String get howWellPeopleKnowEachOther => 'À quel point les personnes se connaissent-elles?';

  @override
  String get moodTone => 'Humeur/Ton';

  @override
  String get selectTonesForQuestions => 'Sélectionnez un ou plusieurs tons souhaités pour les questions';

  @override
  String get context => 'Contexte';

  @override
  String get settingForConversation => 'Dans quel cadre cette conversation aura-t-elle lieu?';

  @override
  String get howChallengingQuestionsBecome => 'À quel point les questions devraient-elles être difficiles ou personnelles?';

  @override
  String get goalOfInteraction => 'Objectif de l\'Interaction';

  @override
  String get whatQuestionsAccomplish => 'Que devraient aider à accomplir ces questions?';

  @override
  String get thematicCategory => 'Catégorie Thématique';

  @override
  String get topicsQuestionsShoulCover => 'Quels types de sujets les questions devraient-elles couvrir?';

  @override
  String get applySettings => 'Appliquer les Paramètres';

  @override
  String get settingsUpdatedSuccessfully => 'Paramètres mis à jour avec succès';

  @override
  String get conversationProfiles => 'Profils de Conversation';

  @override
  String get noProfilesYet => 'Pas encore de profils. Créez votre premier profil!';

  @override
  String get configureSettings => 'Configurer les paramètres';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get deleteProfile => 'Supprimer le profil';

  @override
  String get createNewProfile => 'Créer un Nouveau Profil';

  @override
  String get editProfileTitle => 'Modifier le Profil';

  @override
  String get profileName => 'Nom du Profil';

  @override
  String get descriptionOptional => 'Description (optionnelle)';

  @override
  String get pleaseEnterName => 'Veuillez entrer un nom';

  @override
  String get noteAdditionalSettings => 'Remarque: Des paramètres supplémentaires peuvent être configurés dans l\'écran Paramètres.';

  @override
  String get cancel => 'Annuler';

  @override
  String get create => 'Créer';

  @override
  String get save => 'Enregistrer';

  @override
  String deleteProfileConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\"? Cette action ne peut pas être annulée.';
  }

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get german => 'Allemand';

  @override
  String get openAiProvider => 'OpenAI';

  @override
  String get anthropicProvider => 'Anthropic';

  @override
  String get geminiProvider => 'Gemini';

  @override
  String get depthAcquaintances => 'Connaissances';

  @override
  String get depthFriends => 'Amis';

  @override
  String get depthCloseFriends => 'Amis Proches';

  @override
  String get depthPartners => 'Partenaires/Amants';

  @override
  String get moodFunny => 'Drôle/Ludique';

  @override
  String get moodSerious => 'Sérieux/Réfléchi';

  @override
  String get moodDeep => 'Profond/Réflexif';

  @override
  String get moodSensual => 'Sensuel/Intime';

  @override
  String get moodCrazy => 'Fou/Absurde';

  @override
  String get moodProvocative => 'Provocateur/Osé';

  @override
  String get contextCasual => 'Rencontre décontractée';

  @override
  String get contextDate => 'Rendez-vous amoureux';

  @override
  String get contextOnline => 'Conversation en ligne';

  @override
  String get contextParty => 'Ambiance de fête';

  @override
  String get contextPrivate => 'Cadre privé/intime';

  @override
  String get contextRoadTrip => 'Voyage sur la route';

  @override
  String get contextDinner => 'Conversation de dîner';

  @override
  String get comfortSafe => 'Sûr (faible risque)';

  @override
  String get comfortModerate => 'Modéré';

  @override
  String get comfortHighRisk => 'Risque Élevé';

  @override
  String get goalGettingToKnow => 'Mieux se connaître';

  @override
  String get goalDeepening => 'Approfondir l\'intimité';

  @override
  String get goalBreakingIce => 'Briser la glace';

  @override
  String get goalThoughtful => 'Stimuler une discussion réfléchie';

  @override
  String get goalHumor => 'Provoquer l\'humour/le ludisme';

  @override
  String get goalFantasies => 'Explorer les fantasmes/désirs';

  @override
  String get categoryPast => 'Expériences passées';

  @override
  String get categoryValues => 'Valeurs/croyances personnelles';

  @override
  String get categoryHypothetical => 'Scénarios hypothétiques';

  @override
  String get categoryDreams => 'Rêves/objectifs/ambitions';

  @override
  String get categoryPreferences => 'Préférences';

  @override
  String get categoryRelationships => 'Relations/intimité';

  @override
  String get categorySecrets => 'Secrets/confessions';
}

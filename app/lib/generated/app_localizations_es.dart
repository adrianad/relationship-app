// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App de Relaciones';

  @override
  String get relationshipQuestions => 'Preguntas de Relación';

  @override
  String get manageProfiles => 'Gestionar Perfiles';

  @override
  String get settings => 'Configuración';

  @override
  String settingsFor(String name) {
    return 'Configuración para $name';
  }

  @override
  String get noActiveProfile => 'No se encontró un perfil activo. Por favor, crea un perfil primero.';

  @override
  String get rateThisQuestion => 'Califica esta pregunta:';

  @override
  String get newQuestion => 'Nueva pregunta';

  @override
  String get moreLikeThis => 'Más como esta...';

  @override
  String get lessLikeThis => 'Menos como esta...';

  @override
  String get errorLoadingQuestion => 'Error al cargar la pregunta. Por favor, inténtalo de nuevo.';

  @override
  String get relevance => 'Relevancia';

  @override
  String get comfortLevel => 'Nivel de Comodidad';

  @override
  String get enjoyment => 'Disfrute';

  @override
  String get depthAppropriateness => 'Adecuación de Profundidad';

  @override
  String get intimacyAppropriateness => 'Adecuación de Intimidad';

  @override
  String get veryRelevant => 'Muy relevante';

  @override
  String get somewhatRelevant => 'Algo relevante';

  @override
  String get notRelevant => 'No relevante';

  @override
  String get comfortable => 'Cómodo';

  @override
  String get neutral => 'Neutral';

  @override
  String get uncomfortable => 'Incómodo';

  @override
  String get enjoyable => 'Agradable';

  @override
  String get notEnjoyable => 'No agradable';

  @override
  String get tooDeep => 'Demasiado profundo';

  @override
  String get justRight => 'Adecuado';

  @override
  String get tooShallow => 'Demasiado superficial';

  @override
  String get tooIntimate => 'Demasiado íntimo';

  @override
  String get appropriate => 'Apropiado';

  @override
  String get notIntimateEnough => 'No suficientemente íntimo';

  @override
  String get questionGenerationSettings => 'Configuración de Generación de Preguntas';

  @override
  String get llmProvider => 'Proveedor de LLM';

  @override
  String get selectAiProviderHint => 'Selecciona qué proveedor de IA usar para generar preguntas';

  @override
  String get depthOfRelationship => 'Profundidad de la Relación';

  @override
  String get howWellPeopleKnowEachOther => '¿Qué tan bien se conocen las personas?';

  @override
  String get moodTone => 'Estado de Ánimo/Tono';

  @override
  String get selectTonesForQuestions => 'Selecciona uno o más tonos deseados para las preguntas';

  @override
  String get context => 'Contexto';

  @override
  String get settingForConversation => '¿En qué entorno tendrá lugar esta conversación?';

  @override
  String get howChallengingQuestionsBecome => '¿Qué tan desafiantes o personales deberían ser las preguntas?';

  @override
  String get goalOfInteraction => 'Objetivo de la Interacción';

  @override
  String get whatQuestionsAccomplish => '¿Qué deberían ayudar a lograr estas preguntas?';

  @override
  String get thematicCategory => 'Categoría Temática';

  @override
  String get topicsQuestionsShoulCover => '¿Qué tipo de temas deberían cubrir las preguntas?';

  @override
  String get applySettings => 'Aplicar Configuración';

  @override
  String get settingsUpdatedSuccessfully => 'Configuración actualizada con éxito';

  @override
  String get conversationProfiles => 'Perfiles de Conversación';

  @override
  String get noProfilesYet => 'Aún no hay perfiles. ¡Crea tu primer perfil!';

  @override
  String get configureSettings => 'Configurar ajustes';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get deleteProfile => 'Eliminar perfil';

  @override
  String get createNewProfile => 'Crear Nuevo Perfil';

  @override
  String get editProfileTitle => 'Editar Perfil';

  @override
  String get profileName => 'Nombre del Perfil';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get pleaseEnterName => 'Por favor, introduce un nombre';

  @override
  String get noteAdditionalSettings => 'Nota: Se pueden configurar ajustes adicionales en la pantalla de Configuración.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get save => 'Guardar';

  @override
  String deleteProfileConfirmation(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get german => 'Alemán';

  @override
  String get openAiProvider => 'OpenAI';

  @override
  String get anthropicProvider => 'Anthropic';

  @override
  String get geminiProvider => 'Gemini';

  @override
  String get depthAcquaintances => 'Conocidos';

  @override
  String get depthFriends => 'Amigos';

  @override
  String get depthCloseFriends => 'Amigos Cercanos';

  @override
  String get depthPartners => 'Pareja/Amantes';

  @override
  String get moodFunny => 'Divertido/Juguetón';

  @override
  String get moodSerious => 'Serio/Reflexivo';

  @override
  String get moodDeep => 'Profundo/Reflexivo';

  @override
  String get moodSensual => 'Sensual/Íntimo';

  @override
  String get moodCrazy => 'Loco/Absurdo';

  @override
  String get moodProvocative => 'Provocativo/Picante';

  @override
  String get contextCasual => 'Encuentro casual';

  @override
  String get contextDate => 'Cita romántica';

  @override
  String get contextOnline => 'Chat en línea';

  @override
  String get contextParty => 'Entorno de fiesta';

  @override
  String get contextPrivate => 'Entorno privado/íntimo';

  @override
  String get contextRoadTrip => 'Viaje por carretera';

  @override
  String get contextDinner => 'Conversación durante la cena';

  @override
  String get comfortSafe => 'Seguro (bajo riesgo)';

  @override
  String get comfortModerate => 'Moderado';

  @override
  String get comfortHighRisk => 'Alto Riesgo';

  @override
  String get goalGettingToKnow => 'Conocerse mejor';

  @override
  String get goalDeepening => 'Profundizar la intimidad';

  @override
  String get goalBreakingIce => 'Romper el hielo';

  @override
  String get goalThoughtful => 'Estimular discusión profunda';

  @override
  String get goalHumor => 'Provocar humor/diversión';

  @override
  String get goalFantasies => 'Explorar fantasías/deseos';

  @override
  String get categoryPast => 'Experiencias pasadas';

  @override
  String get categoryValues => 'Valores/creencias personales';

  @override
  String get categoryHypothetical => 'Escenarios hipotéticos';

  @override
  String get categoryDreams => 'Sueños/metas/ambiciones';

  @override
  String get categoryPreferences => 'Preferencias';

  @override
  String get categoryRelationships => 'Relaciones/intimidad';

  @override
  String get categorySecrets => 'Secretos/confesiones';

  @override
  String get shareQuestion => 'Compartir esta pregunta';

  @override
  String get questionOfTheDay => 'Pregunta del Día';

  @override
  String get enableDailyNotification => 'Activar Pregunta Diaria';

  @override
  String get notificationTime => 'Hora de Notificación';

  @override
  String get dailyQuestionEnabled => 'Notificación de pregunta diaria activada';

  @override
  String get dailyQuestionDisabled => 'Notificación de pregunta diaria desactivada';
}

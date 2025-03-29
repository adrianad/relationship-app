import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class QuestionRecord {
  final String question;
  // Old parameters (kept for backward compatibility)
  final int intimacyLevel;
  final int depthLevel;
  final int purposeLevel;
  final int rating;
  final bool moreLikeThis;
  final bool lessLikeThis;
  final String? relevance;
  final String? comfortLevel;
  final String? enjoyment;
  final String? depthAppropriateness;
  final String? intimacyAppropriateness;
  
  // New parameters
  final String? depthOfRelationship;
  final String? moodTone;
  final String? context;
  final String? comfortLevelSetting;
  final String? goalOfInteraction;
  final String? thematicCategory;

  QuestionRecord({
    required this.question,
    required this.intimacyLevel,
    required this.depthLevel,
    required this.purposeLevel,
    required this.rating,
    this.moreLikeThis = false,
    this.lessLikeThis = false,
    this.relevance,
    this.comfortLevel,
    this.enjoyment,
    this.depthAppropriateness,
    this.intimacyAppropriateness,
    // New parameters
    this.depthOfRelationship,
    this.moodTone,
    this.context,
    this.comfortLevelSetting,
    this.goalOfInteraction,
    this.thematicCategory,
  });

  // Convert record to CSV row
  List<dynamic> toRow() {
    return [
      question,
      intimacyLevel,
      depthLevel,
      purposeLevel,
      rating,
      moreLikeThis ? 'Yes' : 'No',
      lessLikeThis ? 'Yes' : 'No',
      relevance ?? '',
      comfortLevel ?? '',
      enjoyment ?? '',
      depthAppropriateness ?? '',
      intimacyAppropriateness ?? '',
      // New parameters
      depthOfRelationship ?? '',
      moodTone ?? '',
      context ?? '',
      comfortLevelSetting ?? '',
      goalOfInteraction ?? '',
      thematicCategory ?? '',
    ];
  }

  // Create formatted history entry for LLM prompt
  String toPromptEntry(int index) {
    // Primary representation using new parameters if available
    if (depthOfRelationship != null && moodTone != null && context != null) {
      return '''
$index. "$question"
   - Depth of Relationship: ${depthOfRelationship ?? 'Not specified'}
   - Mood/Tone: ${moodTone ?? 'Not specified'}
   - Context: ${context ?? 'Not specified'}
   - Comfort Level: ${comfortLevelSetting ?? 'Not specified'}
   - Goal of Interaction: ${goalOfInteraction ?? 'Not specified'}
   - Thematic Category: ${thematicCategory ?? 'Not specified'}
   - Rating: $rating/5
   - Feedback: ${relevance ?? 'Not provided'}, ${comfortLevel ?? 'Not provided'}, ${enjoyment ?? 'Not provided'}
''';
    } else {
      // Fallback for old format records
      return '''
$index. "$question"
   - Intimacy: $intimacyLevel | Depth: $depthLevel | Purpose: $purposeLevel
   - Rating: $rating/5
   - Relevance: ${relevance ?? 'Not provided'}
   - Comfort Level: ${comfortLevel ?? 'Not provided'}
   - Enjoyment: ${enjoyment ?? 'Not provided'}
   - Depth Appropriateness: ${depthAppropriateness ?? 'Not provided'}
   - Intimacy Appropriateness: ${intimacyAppropriateness ?? 'Not provided'}
''';
    }
  }
}

class QuestionHistory {
  static const String _fileName = 'question_history.csv';
  static const List<String> _headers = [
    'Question',
    'Intimacy Level',
    'Depth Level',
    'Purpose Level',
    'Rating',
    'More Like This',
    'Less Like This',
    'Relevance',
    'Comfort Level',
    'Enjoyment',
    'Depth Appropriateness',
    'Intimacy Appropriateness',
    // New parameters
    'Depth of Relationship',
    'Mood/Tone',
    'Context',
    'Comfort Level Setting',
    'Goal of Interaction',
    'Thematic Category',
  ];

  // Get file path
  static Future<String> get _filePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  // Add a new record
  static Future<void> addRecord(QuestionRecord record) async {
    try {
      final path = await _filePath;
      final file = File(path);
      
      List<List<dynamic>> csvData = [];
      
      // If file exists, read existing data
      if (await file.exists()) {
        final contents = await file.readAsString();
        csvData = const CsvToListConverter().convert(contents);
        
        // If the file is empty or corrupted, add headers
        if (csvData.isEmpty) {
          csvData.add(_headers);
        }
      } else {
        // Create new file with headers
        csvData.add(_headers);
      }
      
      // Add the new record
      csvData.add(record.toRow());
      
      // Write updated data back to file
      final csv = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csv);
    } catch (e) {
      print('Error saving question record: $e');
    }
  }

  // Get all records
  static Future<List<QuestionRecord>> getAllRecords() async {
    try {
      final path = await _filePath;
      final file = File(path);
      
      if (!await file.exists()) {
        return [];
      }
      
      final contents = await file.readAsString();
      final csvData = const CsvToListConverter().convert(contents);
      
      // If file is empty or only has headers
      if (csvData.isEmpty || csvData.length == 1) {
        return [];
      }
      
      // Skip the header row
      final recordsList = csvData.sublist(1).map((row) {
        // Handle varying column counts for backward compatibility
        return QuestionRecord(
          question: row[0].toString(),
          intimacyLevel: int.tryParse(row[1].toString()) ?? 5,
          depthLevel: int.tryParse(row[2].toString()) ?? 5,
          purposeLevel: int.tryParse(row[3].toString()) ?? 5,
          rating: int.tryParse(row[4].toString()) ?? 0,
          moreLikeThis: row[5].toString() == 'Yes',
          lessLikeThis: row[6].toString() == 'Yes',
          relevance: row[7].toString().isNotEmpty ? row[7].toString() : null,
          comfortLevel: row[8].toString().isNotEmpty ? row[8].toString() : null,
          enjoyment: row[9].toString().isNotEmpty ? row[9].toString() : null,
          depthAppropriateness: row[10].toString().isNotEmpty ? row[10].toString() : null,
          intimacyAppropriateness: row[11].toString().isNotEmpty ? row[11].toString() : null,
          // New parameters with safety check for column count
          depthOfRelationship: row.length > 12 && row[12].toString().isNotEmpty ? row[12].toString() : null,
          moodTone: row.length > 13 && row[13].toString().isNotEmpty ? row[13].toString() : null,
          context: row.length > 14 && row[14].toString().isNotEmpty ? row[14].toString() : null,
          comfortLevelSetting: row.length > 15 && row[15].toString().isNotEmpty ? row[15].toString() : null,
          goalOfInteraction: row.length > 16 && row[16].toString().isNotEmpty ? row[16].toString() : null,
          thematicCategory: row.length > 17 && row[17].toString().isNotEmpty ? row[17].toString() : null,
        );
      }).toList();
      
      return recordsList;
    } catch (e) {
      print('Error reading question records: $e');
      return [];
    }
  }

  // Get formatted question history for LLM prompt
  static Future<String> getFormattedHistory({int maxRecords = 5}) async {
    final records = await getAllRecords();
    
    if (records.isEmpty) {
      return '';
    }
    
    // Take the most recent records, up to maxRecords
    final recentRecords = records.length <= maxRecords 
      ? records 
      : records.sublist(records.length - maxRecords);
    
    // Build the formatted history string
    String historyText = '\n**Avoid repeating previously asked questions** listed below (with provided feedback):\n\n';
    
    for (int i = 0; i < recentRecords.length; i++) {
      historyText += recentRecords[i].toPromptEntry(i + 1);
      
      // Add spacing between entries
      if (i < recentRecords.length - 1) {
        historyText += '\n';
      }
    }
    
    return historyText;
  }
}
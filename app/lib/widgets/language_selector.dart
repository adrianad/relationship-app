import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/providers/question_provider.dart';
import 'package:app/generated/app_localizations.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);
    
    // Filter languages based on search query
    final filteredLocales = languageProvider.supportedLocales
        .where((locale) => languageProvider.languageMatchesSearch(locale, _searchQuery))
        .toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language section header
          Row(
            children: [
              const Icon(Icons.language, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                localizations.language,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Current language display
          if (!_isExpanded) _buildCurrentLanguageCard(context, languageProvider),
          
          // Expanded language selector with search
          if (_isExpanded) _buildLanguageSelector(context, languageProvider, filteredLocales),
        ],
      ),
    );
  }
  
  Widget _buildCurrentLanguageCard(BuildContext context, LanguageProvider languageProvider) {
    final currentLocale = languageProvider.currentLocale;
    final languageData = languageProvider.getLanguageData(currentLocale);
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = true;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                languageData.flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLocalizedLanguageName(context, currentLocale),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      languageData.nativeName,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLanguageSelector(
    BuildContext context, 
    LanguageProvider languageProvider, 
    List<Locale> filteredLocales
  ) {
    final localizations = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Search input field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "${localizations.language}...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _isExpanded = false;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              autofocus: true,
            ),
          ),
          
          // Language list
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Column(
              children: filteredLocales.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No languages found'),
                      )
                    ]
                  : filteredLocales.map((locale) {
                      final isSelected = languageProvider.currentLocale == locale;
                      final languageData = languageProvider.getLanguageData(locale);
                      
                      return Card(
                        elevation: isSelected ? 3 : 0,
                        color: isSelected ? Colors.blue.shade50 : null,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Text(
                            languageData.flag,
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(
                            _getLocalizedLanguageName(context, locale),
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            // Show native name unless it's the same as the localized name
                            languageData.nativeName == _getLocalizedLanguageName(context, locale)
                                ? ''
                                : languageData.nativeName,
                          ),
                          trailing: isSelected 
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () async {
                            // Change language immediately
                            await languageProvider.changeLanguage(locale);
                            
                            // Show a snackbar confirming the change
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Text(
                                        languageData.flag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 10),
                                      Text('${localizations.language}: ${_getLocalizedLanguageName(context, locale)}'),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                            
                            // Update default question text for the new language
                            if (context.mounted) {
                              Provider.of<QuestionProvider>(context, listen: false)
                                .updateDefaultQuestion(locale.languageCode);
                            }
                            
                            // Close the selector
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _isExpanded = false;
                            });
                          },
                        ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getLocalizedLanguageName(BuildContext context, Locale locale) {
    final localizations = AppLocalizations.of(context);
    
    switch (locale.languageCode) {
      case 'en':
        return localizations.english;
      case 'es':
        return localizations.spanish;
      case 'fr':
        return localizations.french;
      case 'de':
        return localizations.german;
      default:
        return localizations.english;
    }
  }
}
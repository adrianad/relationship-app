import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/question_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Selected LLM provider
  String _selectedProvider = 'OpenAI';
  final List<String> _providers = ['OpenAI', 'Anthropic', 'Gemini'];
  
  // Selected options for multi-selects
  List<String> _selectedMoodTone = ['Funny/Playful'];
  List<String> _selectedGoals = ['Getting to know each other better'];
  List<String> _selectedCategories = ['Past experiences'];

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    
    // Initialize values from provider
    _selectedProvider = questionProvider.currentProvider;
    _selectedMoodTone = List.from(questionProvider.moodTone);
    _selectedGoals = List.from(questionProvider.goalOfInteraction);
    _selectedCategories = List.from(questionProvider.thematicCategory);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Question Generation Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // LLM Provider selection
            const Text('LLM Provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Select which AI provider to use for generating questions',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _providers.map((provider) {
                return DropdownMenuItem(
                  value: provider,
                  child: Text(provider),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvider = value!;
                });
              },
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            
            // Depth of Relationship
            const Text('Depth of Relationship', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'How well do the people know each other?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: questionProvider.depthOfRelationship,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: questionProvider.depthOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  questionProvider.updateSettings(depthOfRelationship: value);
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Mood/Tone (multi-select)
            const Text('Mood/Tone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Select one or more desired tones for the questions',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: questionProvider.moodOptions.map((option) {
                final isSelected = _selectedMoodTone.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMoodTone.add(option);
                      } else {
                        _selectedMoodTone.remove(option);
                      }
                      // Don't allow empty selection
                      if (_selectedMoodTone.isEmpty) {
                        _selectedMoodTone.add(option);
                      }
                      questionProvider.updateSettings(moodTone: _selectedMoodTone);
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Context
            const Text('Context', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'In what setting will this conversation take place?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: questionProvider.context,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: questionProvider.contextOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  questionProvider.updateSettings(context: value);
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Comfort Level
            const Text('Comfort Level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'How challenging or personal should the questions be?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: questionProvider.comfortLevel,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: questionProvider.comfortOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  questionProvider.updateSettings(comfortLevel: value);
                }
              },
            ),
            
            const SizedBox(height: 24),
            
            // Goal of Interaction (multi-select)
            const Text('Goal of Interaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'What should these questions help accomplish?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: questionProvider.goalOptions.map((option) {
                final isSelected = _selectedGoals.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGoals.add(option);
                      } else {
                        _selectedGoals.remove(option);
                      }
                      // Don't allow empty selection
                      if (_selectedGoals.isEmpty) {
                        _selectedGoals.add(option);
                      }
                      questionProvider.updateSettings(goalOfInteraction: _selectedGoals);
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Thematic Category (multi-select)
            const Text('Thematic Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'What kinds of topics should the questions cover?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: questionProvider.categoryOptions.map((option) {
                final isSelected = _selectedCategories.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(option);
                      } else {
                        _selectedCategories.remove(option);
                      }
                      // Don't allow empty selection
                      if (_selectedCategories.isEmpty) {
                        _selectedCategories.add(option);
                      }
                      questionProvider.updateSettings(thematicCategory: _selectedCategories);
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
            
            // Apply settings button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveSettings(questionProvider),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Apply Settings'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveSettings(QuestionProvider provider) async {
    // Update the provider selection if changed
    if (provider.currentProvider != _selectedProvider) {
      await provider.setProvider(_selectedProvider);
    }
    
    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
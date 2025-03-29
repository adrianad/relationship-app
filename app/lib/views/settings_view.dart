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

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);

    // Initialize sliders with values from provider
    double intimacyLevel = questionProvider.intimacyLevel.toDouble();
    double depthLevel = questionProvider.depthLevel.toDouble();
    double purposeLevel = questionProvider.purposeLevel.toDouble();
    _selectedProvider = questionProvider.currentProvider;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Question Parameters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              items:
                  _providers.map((provider) {
                    return DropdownMenuItem(value: provider, child: Text(provider));
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

            // Intimacy Level Slider
            _buildSettingSection(
              title: 'Intimacy Level',
              description: 'Controls how personal or intimate the questions will be',
              value: intimacyLevel,
              onChanged: (value) {
                setState(() {
                  questionProvider.updateSettings(intimacy: value.toInt());
                });
              },
              startLabel: 'Innocent',
              midLabel: 'Sensual',
              endLabel: 'Sexual',
            ),

            const Divider(height: 32),

            // Depth Level Slider
            _buildSettingSection(
              title: 'Depth',
              description: 'Controls how deep or philosophical the questions will be',
              value: depthLevel,
              onChanged: (value) {
                setState(() {
                  questionProvider.updateSettings(depth: value.toInt());
                });
              },
              startLabel: 'Surface-level',
              midLabel: 'Intermediate',
              endLabel: 'Deep',
            ),

            const Divider(height: 32),

            // Purpose Slider
            _buildSettingSection(
              title: 'Purpose',
              description: 'Controls the intended purpose of the questions',
              value: purposeLevel,
              onChanged: (value) {
                setState(() {
                  questionProvider.updateSettings(purpose: value.toInt());
                });
              },
              startLabel: 'Fun',
              midLabel: 'Bonding/Exploration',
              endLabel: 'Conflict Resolution',
            ),

            const SizedBox(height: 40),

            // Apply settings button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveSettings(questionProvider),
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Apply Settings')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a consistent setting section with slider
  Widget _buildSettingSection({
    required String title,
    required String description,
    required double value,
    required Function(double) onChanged,
    required String startLabel,
    required String midLabel,
    required String endLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 16),

        // Simple slider
        Slider(value: value, min: 1, max: 10, divisions: 9, label: value.round().toString(), onChanged: onChanged),

        // Slider labels positioned at left, exact middle, and right
        Stack(
          children: [
            // Container for setting the height
            Container(height: 30, width: double.infinity),
            // Left label with value
            Positioned(
              left: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("1", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(startLabel, style: TextStyle(color: Colors.grey[700], fontSize: 11)),
                ],
              ),
            ),
            // Middle label with value
            Positioned(
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text("5", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 11)),
                    Text(midLabel, style: TextStyle(color: Colors.grey[700], fontSize: 11)),
                  ],
                ),
              ),
            ),
            // Right label with value
            Positioned(
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("10", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(endLabel, style: TextStyle(color: Colors.grey[700], fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveSettings(QuestionProvider provider) async {
    // Update the provider selection if changed
    if (provider.currentProvider != _selectedProvider) {
      await provider.setProvider(_selectedProvider);
    }

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings updated successfully'), duration: Duration(seconds: 2)));
    }
  }
}

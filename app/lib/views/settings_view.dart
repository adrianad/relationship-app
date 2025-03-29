import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  // Slider values with default settings
  double _intimacyLevel = 5.0;
  double _depthLevel = 5.0;
  double _purposeLevel = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Question Parameters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Intimacy Level Slider
            _buildSettingSection(
              title: 'Intimacy Level',
              description: 'Controls how personal or intimate the questions will be',
              value: _intimacyLevel,
              onChanged: (value) {
                setState(() {
                  _intimacyLevel = value;
                });
              },
              startLabel: 'Innocent',
              midLabel: 'Personal',
              endLabel: 'Sexual',
            ),

            const Divider(height: 32),

            // Depth Level Slider
            _buildSettingSection(
              title: 'Depth',
              description: 'Controls how deep or philosophical the questions will be',
              value: _depthLevel,
              onChanged: (value) {
                setState(() {
                  _depthLevel = value;
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
              value: _purposeLevel,
              onChanged: (value) {
                setState(() {
                  _purposeLevel = value;
                });
              },
              startLabel: 'Fun',
              midLabel: 'Exploration/Bonding',
              endLabel: 'Conflict Resolution',
            ),

            const SizedBox(height: 40),

            // Apply settings button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
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
            Container(
              height: 20,
              width: double.infinity,
            ),
            // Left label
            Positioned(
              left: 0,
              child: Text(
                startLabel,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ),
            // Middle label
            Positioned(
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  midLabel,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            // Right label
            Positioned(
              right: 0,
              child: Text(
                endLabel,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings updated successfully'), duration: Duration(seconds: 2)));
  }
}

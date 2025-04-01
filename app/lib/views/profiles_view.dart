import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:app/models/profile.dart';
import 'package:app/generated/app_localizations.dart';

class ProfilesView extends StatefulWidget {
  const ProfilesView({super.key});

  @override
  State<ProfilesView> createState() => _ProfilesViewState();
}

class _ProfilesViewState extends State<ProfilesView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Default values for new profile
  String _selectedProvider = 'OpenAI';
  String _selectedDepth = 'Friends';
  String _selectedComfort = 'Moderate';
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.conversationProfiles),
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Error message if any
                if (profileProvider.errorMessage.isNotEmpty)
                  Container(
                    color: Colors.red.shade100,
                    padding: const EdgeInsets.all(8.0),
                    width: double.infinity,
                    child: Text(
                      profileProvider.errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                
                // Profile list
                Expanded(
                  child: profileProvider.profiles.isEmpty
                      ? Center(child: Text(localizations.noProfilesYet))
                      : ListView.builder(
                          itemCount: profileProvider.profiles.length,
                          itemBuilder: (context, index) {
                            final profile = profileProvider.profiles[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Radio<int>(
                                  value: profile.id!,
                                  groupValue: profileProvider.activeProfile?.id,
                                  onChanged: (value) {
                                    if (value != null) {
                                      profileProvider.setActiveProfile(value);
                                    }
                                  },
                                ),
                                title: Text(profile.name),
                                subtitle: Text(profile.description),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: localizations.editProfile,
                                      onPressed: () => _showEditDialog(context, profile),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: localizations.deleteProfile,
                                      onPressed: profileProvider.profiles.length <= 1
                                          ? null  // Disable deletion of last profile
                                          : () => _showDeleteDialog(context, profile),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  if (profile.id != profileProvider.activeProfile?.id) {
                                    profileProvider.setActiveProfile(profile.id!);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    
    // Reset form fields
    _nameController.text = '';
    _descriptionController.text = '';
    _selectedProvider = 'OpenAI';
    _selectedDepth = 'Friends';
    _selectedComfort = 'Moderate';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.createNewProfile),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: localizations.profileName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.pleaseEnterName;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: localizations.descriptionOptional),
                ),
                const SizedBox(height: 16),
                
                // Show depth of relationship, comfort level, and LLM provider settings
                DropdownButtonFormField<String>(
                  value: _selectedDepth,
                  decoration: InputDecoration(labelText: localizations.depthOfRelationship),
                  items: ['Acquaintances', 'Friends', 'Close Friends', 'Partners/Lovers']
                      .map((option) => DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDepth = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedComfort,
                  decoration: InputDecoration(labelText: localizations.comfortLevel),
                  items: ['Safe (low risk)', 'Moderate', 'High Risk']
                      .map((option) => DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedComfort = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: InputDecoration(labelText: localizations.llmProvider),
                  items: ['OpenAI', 'Anthropic', 'Gemini']
                      .map((option) => DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedProvider = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Create profile with default question settings, customizing name, description, depth, comfort and LLM provider
                final newProfile = Profile.defaultProfile().copyWith(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  depthOfRelationship: _selectedDepth,
                  comfortLevel: _selectedComfort,
                  llmProvider: _selectedProvider,
                );
                
                profileProvider.createProfile(newProfile).then((_) {
                  Navigator.pop(context);
                });
              }
            },
            child: Text(localizations.create),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Profile profile) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    
    // Initialize controllers with current values
    _nameController.text = profile.name;
    _descriptionController.text = profile.description;
    _selectedDepth = profile.depthOfRelationship;
    _selectedComfort = profile.comfortLevel;
    _selectedProvider = profile.llmProvider;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.editProfileTitle),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: localizations.profileName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.pleaseEnterName;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: localizations.descriptionOptional),
                ),
                const SizedBox(height: 16),
                
                // Show depth of relationship, comfort level, and LLM provider settings
                DropdownButtonFormField<String>(
                  value: _selectedDepth,
                  decoration: InputDecoration(labelText: localizations.depthOfRelationship),
                  items: ['Acquaintances', 'Friends', 'Close Friends', 'Partners/Lovers']
                      .map((option) => DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDepth = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedComfort,
                  decoration: InputDecoration(labelText: localizations.comfortLevel),
                  items: ['Safe (low risk)', 'Moderate', 'High Risk']
                      .map((option) => DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedComfort = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: InputDecoration(labelText: localizations.llmProvider),
                  items: ['OpenAI', 'Anthropic', 'Gemini']
                      .map((option) => DropdownMenuItem(value: option, child: Text(getLocalizedOption(context, option))))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedProvider = value);
                    }
                  },
                ),
                
                Text(localizations.noteAdditionalSettings),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Update name, description, depth, comfort level and LLM provider
                final updatedProfile = profile.copyWith(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  depthOfRelationship: _selectedDepth,
                  comfortLevel: _selectedComfort,
                  llmProvider: _selectedProvider,
                );
                
                profileProvider.updateProfile(updatedProfile).then((_) {
                  Navigator.pop(context);
                });
              }
            },
            child: Text(localizations.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Profile profile) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.deleteProfile),
        content: Text(localizations.deleteProfileConfirmation(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              profileProvider.deleteProfile(profile.id!).then((_) {
                Navigator.pop(context);
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.deleteProfile),
          ),
        ],
      ),
    );
  }
  
  // Helper function to get localized text for options while keeping original values for the prompt
  String getLocalizedOption(BuildContext context, String option) {
    final localizations = AppLocalizations.of(context);
    
    // LLM Provider
    if (option == 'OpenAI') return localizations.openAiProvider;
    if (option == 'Anthropic') return localizations.anthropicProvider;
    if (option == 'Gemini') return localizations.geminiProvider;
    
    // Depth Options
    if (option == 'Acquaintances') return localizations.depthAcquaintances;
    if (option == 'Friends') return localizations.depthFriends;
    if (option == 'Close Friends') return localizations.depthCloseFriends;
    if (option == 'Partners/Lovers') return localizations.depthPartners;
    
    // Comfort Options
    if (option == 'Safe (low risk)') return localizations.comfortSafe;
    if (option == 'Moderate') return localizations.comfortModerate;
    if (option == 'High Risk') return localizations.comfortHighRisk;
    
    // Default fallback
    return option;
  }
}
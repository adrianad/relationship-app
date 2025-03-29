import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/profile_provider.dart';
import 'package:app/models/profile.dart';

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
  String _selectedDepth = 'Friends';
  List<String> _selectedMoodTone = ['Funny/Playful'];
  String _selectedContext = 'Casual hangout';
  String _selectedComfort = 'Moderate';
  List<String> _selectedGoals = ['Getting to know each other better'];
  List<String> _selectedCategories = ['Past experiences'];
  String _selectedProvider = 'OpenAI';
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Profiles'),
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
                      ? const Center(child: Text('No profiles yet. Create your first profile!'))
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
                                    // Settings button
                                    IconButton(
                                      icon: const Icon(Icons.settings),
                                      tooltip: 'Configure settings',
                                      onPressed: () {
                                        // Set this profile as active
                                        if (profile.id != profileProvider.activeProfile?.id) {
                                          profileProvider.setActiveProfile(profile.id!);
                                        }
                                        // Navigate to settings
                                        Navigator.pushNamed(context, '/settings');
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit profile',
                                      onPressed: () => _showEditDialog(context, profile),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Delete profile',
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
    
    // Reset form fields
    _nameController.text = '';
    _descriptionController.text = '';
    _selectedDepth = 'Friends';
    _selectedMoodTone = ['Funny/Playful'];
    _selectedContext = 'Casual hangout';
    _selectedComfort = 'Moderate';
    _selectedGoals = ['Getting to know each other better'];
    _selectedCategories = ['Past experiences'];
    _selectedProvider = 'OpenAI';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Profile'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Profile Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 16),
                
                // Only show the basic settings for now to keep the dialog simple
                DropdownButtonFormField<String>(
                  value: _selectedDepth,
                  decoration: const InputDecoration(labelText: 'Depth of Relationship'),
                  items: ['Acquaintances', 'Friends', 'Close Friends', 'Partners/Lovers']
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDepth = value);
                    }
                  },
                ),
                
                DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: const InputDecoration(labelText: 'LLM Provider'),
                  items: ['OpenAI', 'Anthropic', 'Gemini']
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newProfile = Profile(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  depthOfRelationship: _selectedDepth,
                  moodTone: _selectedMoodTone,
                  context: _selectedContext,
                  comfortLevel: _selectedComfort,
                  goalOfInteraction: _selectedGoals,
                  thematicCategory: _selectedCategories,
                  llmProvider: _selectedProvider,
                );
                
                profileProvider.createProfile(newProfile).then((_) {
                  Navigator.pop(context);
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Profile profile) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    // Initialize controllers with current values
    _nameController.text = profile.name;
    _descriptionController.text = profile.description;
    _selectedDepth = profile.depthOfRelationship;
    _selectedMoodTone = List.from(profile.moodTone);
    _selectedContext = profile.context;
    _selectedComfort = profile.comfortLevel;
    _selectedGoals = List.from(profile.goalOfInteraction);
    _selectedCategories = List.from(profile.thematicCategory);
    _selectedProvider = profile.llmProvider;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Profile Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 16),
                
                // Basic settings for the edit dialog
                DropdownButtonFormField<String>(
                  value: _selectedDepth,
                  decoration: const InputDecoration(labelText: 'Depth of Relationship'),
                  items: ['Acquaintances', 'Friends', 'Close Friends', 'Partners/Lovers']
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedDepth = value);
                    }
                  },
                ),
                
                DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: const InputDecoration(labelText: 'LLM Provider'),
                  items: ['OpenAI', 'Anthropic', 'Gemini']
                      .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedProvider = value);
                    }
                  },
                ),
                
                const Text('Note: Additional settings can be configured in the Settings screen.'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final updatedProfile = profile.copyWith(
                  name: _nameController.text,
                  description: _descriptionController.text,
                  depthOfRelationship: _selectedDepth,
                  llmProvider: _selectedProvider,
                );
                
                profileProvider.updateProfile(updatedProfile).then((_) {
                  Navigator.pop(context);
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Profile profile) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete "${profile.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              profileProvider.deleteProfile(profile.id!).then((_) {
                Navigator.pop(context);
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
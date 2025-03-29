import 'package:flutter/material.dart';
import 'package:app/models/profile.dart';
import 'package:app/database/database_helper.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Profile> _profiles = [];
  Profile? _activeProfile;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Getters
  List<Profile> get profiles => _profiles;
  Profile? get activeProfile => _activeProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Initialize the provider
  ProfileProvider() {
    _loadProfiles();
  }
  
  // Load all profiles and set active profile
  Future<void> _loadProfiles() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      _profiles = await _db.getAllProfiles();
      _activeProfile = await _db.getActiveProfile();
      
      // If no active profile, create and set default profile
      if (_activeProfile == null && _profiles.isEmpty) {
        final defaultProfile = Profile.defaultProfile();
        final id = await _db.insertProfile(defaultProfile);
        await _db.setActiveProfile(id);
        
        // Reload profiles
        _profiles = await _db.getAllProfiles();
        _activeProfile = await _db.getActiveProfile();
      } else if (_activeProfile == null && _profiles.isNotEmpty) {
        // If profiles exist but none active, set the first as active
        await _db.setActiveProfile(_profiles.first.id!);
        _activeProfile = await _db.getActiveProfile();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profiles: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new profile
  Future<void> createProfile(Profile profile) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final id = await _db.insertProfile(profile);
      
      // If this is the only profile, make it active
      if (_profiles.isEmpty) {
        await _db.setActiveProfile(id);
      }
      
      await _loadProfiles();
    } catch (e) {
      _errorMessage = 'Failed to create profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update a profile
  Future<void> updateProfile(Profile profile) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _db.updateProfile(profile);
      await _loadProfiles();
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete a profile
  Future<void> deleteProfile(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _db.deleteProfile(id);
      
      // If deleting active profile, set another as active
      if (_activeProfile?.id == id) {
        final remainingProfiles = await _db.getAllProfiles();
        if (remainingProfiles.isNotEmpty) {
          await _db.setActiveProfile(remainingProfiles.first.id!);
        }
      }
      
      await _loadProfiles();
    } catch (e) {
      _errorMessage = 'Failed to delete profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Set a profile as active
  Future<void> setActiveProfile(int id) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _db.setActiveProfile(id);
      await _loadProfiles();
    } catch (e) {
      _errorMessage = 'Failed to set active profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:health_chain/services/user_service.dart';

class DoctorProfileViewModel extends ChangeNotifier {
  final UserService _userService;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  DoctorProfileViewModel(this._userService);

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _userService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _userService.updateUser(updates);
      await loadProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
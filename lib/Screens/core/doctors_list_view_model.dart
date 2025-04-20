import 'package:flutter/material.dart';
import 'package:health_chain/services/user_service.dart';

class DoctorsListViewModel extends ChangeNotifier {
  final UserService _userService;
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = false;
  String? _error;

  DoctorsListViewModel(this._userService);

  List<Map<String, dynamic>> get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDoctors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctors = await _userService.getDoctors();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
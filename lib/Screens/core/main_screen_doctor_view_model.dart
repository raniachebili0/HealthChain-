import 'package:flutter/material.dart';
import 'package:health_chain/services/user_service.dart';

class MainScreenDoctorViewModel extends ChangeNotifier {
  final UserService _userService;
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _error;

  MainScreenDoctorViewModel(this._userService);

  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadDoctorData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement loading doctor's data
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 
import 'package:flutter/material.dart';
import 'package:health_chain/services/user_service.dart';

class CreateAppointmentViewModel extends ChangeNotifier {
  final UserService _userService;
  final String doctorId;
  bool _isLoading = false;
  String? _error;

  CreateAppointmentViewModel({
    required UserService userService,
    required this.doctorId,
  }) : _userService = userService;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createAppointment({
    required String date,
    required String time,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final appointmentData = {
        "doctorId": doctorId,
        "date": date,
        "time": time,
      };

      await _userService.createAppointment(appointmentData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
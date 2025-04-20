import 'package:flutter/material.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/Screens/core/docter_detailles_screnn.dart';

class HomeViewModel extends ChangeNotifier {
  final UserService _userService;
  List<Map<String, dynamic>>? _doctors;
  bool _isLoading = false;
  String? _error;

  HomeViewModel(this._userService);

  List<Map<String, dynamic>>? get doctors => _doctors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDoctors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _doctors = await _userService.getAllDoctors();
    } catch (e) {
      _error = e.toString();
      print("Error loading doctors: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToDoctorsList(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.doctorsListScreen);
  }

  void navigateToDoctorDetails(BuildContext context, Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctor: doctor),
      ),
    );
  }

  void navigateToChat(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.chatScreen);
  }

  void checkNow() {
    // Implement check now functionality
    print("Check Now clicked");
  }
} 
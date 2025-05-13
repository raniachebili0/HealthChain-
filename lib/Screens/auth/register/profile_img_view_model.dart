import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageViewModel extends ChangeNotifier {
  final AuthService _authService;
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileImageViewModel(this._authService);

  File? get selectedImage => _selectedImage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> signup({
    required BuildContext context,
    required String email,
    required String gender,
    required String name,
    required String password,
    required String birthDate,
    required String tel,
    required File? image,
    required String? doctorId,
    required String? doctorSpeciality,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userRole =
          (doctorId == null || doctorId.isEmpty) ? "patient" : "practitioner";

      final signupResult = await _authService.signup(
        email: email,
        name: name,
        tel: tel,
        password: password,
        role: userRole,
        birthDate: birthDate,
        gender: gender,
        filePath: image,
        doctorId: doctorId,
        doctorspecility: doctorSpeciality,
      );

      if (signupResult == "success") {
        print("Signup successful!");
        Navigator.pushReplacementNamed(context, '/login_view');
      } else {
        _errorMessage = "Signup failed: $signupResult";
        print(_errorMessage);
      }
    } catch (e) {
      _errorMessage = "An error occurred during signup: $e";
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

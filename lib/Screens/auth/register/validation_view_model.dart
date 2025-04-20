import 'package:flutter/material.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';

class ValidationViewModel extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String _verificationCode = "";
  bool _hasError = false;

  ValidationViewModel(this._authService);

  bool get isLoading => _isLoading;

  String get verificationCode => _verificationCode;

  bool get hasError => _hasError;

  void setVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }

  String validateVerificationCode(String code) {
    if (code.isEmpty) {
      return 'Please enter OTP';
    } else if (code.length != 6) {
      return 'OTP should be 6 digits long';
    }
    return "valide";
  }

  void setError(bool value) {
    _hasError = value;
    notifyListeners();
  }

  Future<void> verifyOtp(BuildContext context, String email, String otp) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(email, otp);
      print("Raw response from verifyOtp: $response");

      if (response == "OTP Verified") {
        print("OTP Verified: $response");
        Navigator.pushReplacementNamed(context, AppRoutes.userFormView);
      } else {
        print("Invalid OTP: $response");
        _hasError = true;
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Implement resend OTP logic here
      print("Resending OTP to: $email");
    } catch (e) {
      print("Error resending OTP: $e");
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

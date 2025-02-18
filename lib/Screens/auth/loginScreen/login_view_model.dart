import 'package:flutter/material.dart';
import 'package:health_chain/routes/app_router.dart';

import '../../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  LoginViewModel(this._authService);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPassVisible = true;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPassVisible = !isPassVisible;
    notifyListeners();
  }

  // Login function
  Future<void> login(BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    bool success = await _authService.login(
      emailController.text,
      passwordController.text,
    );

    isLoading = false;
    notifyListeners();

    if (success) {
      buttonFunction:
      () => Navigator.pushNamed(context, AppRoutes.inscription);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid phone or password")),
      );
    }
  }

  // Validation functions
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email address";
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return "";
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    return "";
  }
}

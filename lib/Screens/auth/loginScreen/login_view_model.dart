import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  final storage = FlutterSecureStorage();

  void buttonAction(BuildContext context, GlobalKey<FormState> formKey) async {
    String email = emailController.text;
    String password = passwordController.text;
    print(email + password);

    if (formKey.currentState!.validate()) {
      print("Form is valid");

      final loginStatus = await _authService.login(email, password);

      if (loginStatus == "Login successful") {
        String? role = await storage.read(key: "user_role");
        print("ddddddddddddddddddd      ${role}");

        if (role == "practitioner") {
          Navigator.pushReplacementNamed(context, '/DoctorBottomNavBar');
        } else {
          Navigator.pushReplacementNamed(context, '/main_screen');
        }
      } else {
        print("Login failed: $loginStatus");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginStatus),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      print("Form not is valid");
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

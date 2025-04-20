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

  final storage = FlutterSecureStorage();

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPassVisible = !isPassVisible;
    notifyListeners();
  }

  void buttonAction(BuildContext context, GlobalKey<FormState> formKey) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    print("Login attempt with email: $email");

    if (formKey.currentState!.validate()) {
      print("Form is valid");

      // Show loading indicator
      isLoading = true;
      notifyListeners();

      try {
        final loginStatus = await _authService.login(email, password);
        print("Login status: $loginStatus");

        if (loginStatus == "Login successful") {
          // Get the user role and ID
          String? role = await storage.read(key: "user_role");
          String? userId = await storage.read(key: "user_id");
          print("User role: $role");
          print("User ID: $userId");

          // Check for specific doctor ID or role
          if (role == "doctor" || userId == "67fbb7e9d7a0e68c02e725d8") {
            print("Navigating to doctor screen - Doctor identified");
            Navigator.pushReplacementNamed(context, AppRoutes.doctormainScreen);
          } else {
            print("Navigating to main screen - Not a doctor");
            Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
          }
        } else {
          print("Login failed: $loginStatus");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login failed: ${loginStatus.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("Error during login: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred during login."),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading = false;
        notifyListeners();
      }
    } else {
      print("Form validation failed");
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter an email address";
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a password";
    }
    return null;
  }
}

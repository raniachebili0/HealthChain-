import 'package:flutter/material.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:http/http.dart' as http;
import 'package:health_chain/config/app_config.dart';
import 'dart:async';
import 'dart:convert';

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
  
  // Check if server is available
  Future<bool> _isServerAvailable() async {
    try {
      final serverUrl = AppConfig.apiBaseUrl.replaceAll(":3000", ":3001");
      print("Checking server availability at: $serverUrl");
      
      final response = await http.get(
        Uri.parse(serverUrl),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode < 500;
    } catch (e) {
      print("Server availability check failed: $e");
      return false;
    }
  }

  void buttonAction(BuildContext context, GlobalKey<FormState> formKey) async {
    String email = emailController.text;
    String password = passwordController.text;
    print("Email: '$email'");
    print("Password: '$password'"); // Print with quotes to see exact value
    
    if (formKey.currentState!.validate()) {
      print("Form is valid");
      
      // Set loading state
      isLoading = true;
      notifyListeners();
      
      try {
        // Check server availability first
        bool isServerAvailable = await _isServerAvailable();
        if (!isServerAvailable) {
          throw Exception("Server is not available. Please check if your backend server is running at ${AppConfig.apiBaseUrl.replaceAll(":3000", ":3001")}");
        }
        
        print("Attempting to login with email: $email");
        
        // Make direct HTTP request to ensure we see full response
        final loginUrl = AppConfig.loginUrl.replaceAll(":3000", ":3001");
        print("Using login URL: $loginUrl");
        
        final response = await http.post(
          Uri.parse(loginUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": email, "password": password}),
        ).timeout(const Duration(seconds: 15));
        
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Parse the response
          final responseData = jsonDecode(response.body);
          
          // Store tokens in secure storage
          String accessToken = responseData["accessToken"];
          String userId = responseData["userId"];
          String role = responseData["role"];
          
          await _authService.storage.write(key: "auth_token", value: accessToken);
          await _authService.storage.write(key: "user_id", value: userId);
          await _authService.storage.write(key: "user_role", value: role);
          
          print("Login successful, navigating to main screen");
          Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
        } else {
          String errorMessage = "Unknown error";
          try {
            // Try to extract error message
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? "Login failed";
          } catch (e) {
            errorMessage = "Failed to connect to server";
          }
          
          print("Login failed: $errorMessage");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: $errorMessage")),
          );
        }
      } catch (e) {
        print("Exception during login: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: $e")),
        );
      } finally {
        isLoading = false;
        notifyListeners();
      }
    } else {
      print("Form is not valid");
    }
  }

  // Validation functions
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email address";
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null; // Return null when validation passes
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a password";
    }
    return null; // Return null when validation passes
  }
}

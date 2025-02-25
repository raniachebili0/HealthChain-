import 'package:flutter/material.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';

class InscriptionViewModel extends ChangeNotifier {
  final AuthService _authService;

  InscriptionViewModel(this._authService);

  final TextEditingController emailController = TextEditingController();
  bool valide = false;

  String? getTempAccountValidation(String? text) {
    if (text == null || text.isEmpty) {
      valide = false;
      notifyListeners();
      return "Please enter an email address";
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text)) {
      // Email regex validation
      valide = false;
      notifyListeners();
      return "Please enter a valid email address";
    } else {
      valide = true;
      notifyListeners();
      return ""; // Return null when validation is successful
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter an email address";
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return "";
  }

  void buttonAction(BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      print(emailController.text);
      final response = await _authService.sendOtp(emailController.text);

      print("Response received: $response");

      // Check if the response contains the "message" key instead of "status"
      if (response.containsKey("error")) {
        print("Error: ${response["error"]}");
        // Show error message to user
      } else if (response["message"] == "OTP sent successfully") {
        // Navigate if OTP is sent successfully
        Navigator.pushNamed(context, AppRoutes.validationDuCompte);
        print("OTP Sent Successfully");
      } else {
        print("Failed to send OTP");
      }
    }
  }
}

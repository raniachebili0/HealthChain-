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

  void buttonAction(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      // This will trigger the form validation and then navigate
      Navigator.pushNamed(context, AppRoutes.validationDuCompte);
    }
  }
}

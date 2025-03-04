import 'package:flutter/cupertino.dart';
import 'package:health_chain/routes/app_router.dart';

class DoctorFormViewModel extends ChangeNotifier {
  TextEditingController doctorIdController = TextEditingController();
  TextEditingController doctorspecialiteController = TextEditingController();

  String getTempAccountValidationDoctorId(String text) {
    if (text.isNotEmpty && text.length != 13) {
      return "Please enter a valid Id";
    }
    return "";
  }

  String getTempAccountValidationDoctorSpeciality(String text) {
    return "";
  }

  // button function
  void buttonAction(GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      Navigator.pushNamed(context, AppRoutes.imagePickerScreen);
      // print(_formKey.currentState!.validate());
      // final _authService = Provider.of<AuthService>(context, listen: false);
      // // Retrieve user input values from form fields
      // String gender = selectedGender;
      // String name = _nomController.text;
      // String password = _mdpController.text;
      // String birthDate = _dateController.text; // Or select from date picker
      // String tel = _telController.text;
      // String role =
      //     "patient"; // Adjust role as needed (e.g., 'patient', 'doctor')
      //
      // // Call signup function
      // String signupResult = await _authService.signup(
      //     email, gender, name, password, birthDate, tel, role);
      //
      // if (signupResult == "success") {
      //   print("Signup successful!");
      //   // Navigate to the next screen
      //   Navigator.pushReplacementNamed(context, AppRoutes.login);
      // } else {
      //   print("Signup failed: $signupResult");
      //   // Show error message to user (optional, you can use a snackbar, dialog, etc.)
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text("Signup failed: $signupResult")));
      // }
    }
  }
}

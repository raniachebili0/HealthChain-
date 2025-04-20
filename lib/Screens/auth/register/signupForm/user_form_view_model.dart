import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../routes/app_router.dart';
import '../../../../utils/colors.dart';

class UserFormViewModel extends ChangeNotifier {
  bool isPassVisible = true;
  FocusNode myFocusNode = FocusNode();
  TextEditingController mdpController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController nomController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  void togglePasswordVisibility() {
    isPassVisible = !isPassVisible;
    notifyListeners();
  }

  String selectedGender = "";
  Color masculinColor = Color.fromRGBO(218, 226, 241, 1.0);
  Color femininColor = Color.fromRGBO(218, 226, 241, 1.0);
  Color textColor = Colors.black87;

  DateTime? date;

  String display() {
    if (date == null) {
      return 'NONE';
    } else {
      return 'year:${date!.year}\nmonth:${date!.month}\nday:$date!.day}';
    }
  }

  void selectGender(String gender) {
    if (gender == "male") {
      selectedGender = gender;
      masculinColor = AppColors.primaryColor;
      femininColor = Color.fromRGBO(218, 226, 241, 1.0);
      notifyListeners();
    } else if (gender == "female") {
      selectedGender = gender;
      femininColor = AppColors.primaryColor;
      masculinColor = Color.fromRGBO(218, 226, 241, 1.0);
      notifyListeners();
    }
  }

  //validation function
  String getTempAccountValidationtel(String text) {
    if (text.isEmpty) {
      return "Please enter your phone number";
    } else if (text.length != 8) {
      return "Please enter a valid phone number";
    }
    return "";
  }

  String getTempAccountValidationmdp(String text) {
    if (text.isEmpty) {
      return "Please enter a password";
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$')
        .hasMatch(text)) {
      return "Please enter a valid phone number password";
    }
    return "";
  }

  String getTempAccountValidationname(String text) {
    if (text.isEmpty) {
      return "Please enter your full name";
    }
    return "";
  }

  // button function
  void buttonAction(GlobalKey<FormState> formKey, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      Navigator.pushNamed(context, AppRoutes.doctorFormView);
      String gender = selectedGender;
      String name = nomController.text;
      String password = mdpController.text;
      String birthDate = dateController.text; // Or select from date picker
      String tel = telController.text;
      String role = "patient";
      print(gender +
          name +
          password +
          birthDate +
          tel +
          role); // Adjust role as needed (e.g., 'patient', 'doctor')
    }
  }
}

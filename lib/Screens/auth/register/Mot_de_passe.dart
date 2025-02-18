import 'package:auto_route/auto_route.dart';
import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../../../models/SharedData.dart';

import '../../../utils/themes.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/button.dart';
import '../../../widgets/textField.dart';

@RoutePage()
class MDPpage extends StatefulWidget {
  const MDPpage({Key? key}) : super(key: key);

  @override
  State<MDPpage> createState() => _MDPpageState();
}

class _MDPpageState extends State<MDPpage> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPassVisible = true;
  FocusNode myFocusNode = new FocusNode();
  TextEditingController _mdpController = TextEditingController();
  TextEditingController _telController = TextEditingController();
  TextEditingController _nomController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  String selectedGender = "";
  Color masculinColor = Color.fromRGBO(218, 226, 241, 1.0);
  Color femininColor = Color.fromRGBO(218, 226, 241, 1.0);
  Color textColor = Colors.black87;

  DateTime? _date;

  String display() {
    if (_date == null) {
      return 'NONE';
    } else {
      return 'year:${_date!.year}\nmonth:${_date!.month}\nday:${_date!.day}';
    }
  }

  void selectGender(String gender) {
    setState(() {
      if (gender == "Masculine") {
        selectedGender = gender;
        masculinColor = AppColors.primaryColor;
        femininColor = Color.fromRGBO(218, 226, 241, 1.0);
      } else if (gender == "Female") {
        selectedGender = gender;
        femininColor = AppColors.primaryColor;
        masculinColor = Color.fromRGBO(218, 226, 241, 1.0);
      }
    });
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
      return "Veuillez saisir un mot de passe valide";
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
  void buttonAction() {
    if (_formKey.currentState!.validate()) {
      final sharedData = Provider.of<SharedData>(context, listen: false);
      sharedData.MDPdata = _mdpController.text;
      Navigator.pushNamed(context, AppRoutes.imagePickerScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              appbartext: 'Sign Up',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(17.w, 0.h, 17.w, 30.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 13.h),
                        child: Text(
                          'let\'s get to know you',
                          style: CustomTextStyle.titleStyle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Text(
                          'enter your information',
                          style: CustomTextStyle.h2,
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: OutlineBorderTextFormField(
                                labelText: "tel",
                                obscureText: false,
                                tempTextEditingController: _telController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return getTempAccountValidationtel(
                                      textToValidate);
                                },
                                mySuffixIcon: null,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: OutlineBorderTextFormField(
                                labelText: "Full Nom",
                                obscureText: false,
                                tempTextEditingController: _nomController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return getTempAccountValidationname(
                                      textToValidate);
                                },
                                mySuffixIcon: null,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 5.h),
                              child: OutlineBorderTextFormField(
                                labelText: "Mot de passe",
                                obscureText: _isPassVisible,
                                tempTextEditingController: _mdpController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return getTempAccountValidationmdp(
                                      textToValidate);
                                },
                                mySuffixIcon: Container(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _isPassVisible = !_isPassVisible;
                                      });
                                    },
                                    child: Image(
                                      image: _isPassVisible
                                          ? AssetImage(
                                              'assets/icons/vector.png')
                                          : AssetImage(
                                              'assets/icons/union.png'),
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Text(
                                'At least 8 characters that contain an uppercase letter, a number and a special character',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xb30e0e0c),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 50.w),
                                    child: Text(
                                      'Birthday',
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xb30e0e0c),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: DateFormatField(
                                      type: DateFormatType.type4,
                                      addCalendar: true,
                                      controller: _dateController,
                                      decoration: InputDecoration(
                                        iconColor: Colors.white,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        filled: true,
                                        fillColor: AppColors.primaryColor,
                                        labelText: "Date",
                                        labelStyle: const TextStyle(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: AppColors.primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                      ),
                                      onComplete: (date) {
                                        setState(() {
                                          _date = date;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: Text(
                                'Gender',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xb30e0e0c),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          selectGender("Masculine");
                                        },
                                        style: ButtonStyle(
                                          elevation:
                                              WidgetStateProperty.all<double>(
                                                  0),
                                          minimumSize: WidgetStateProperty.all(
                                              Size(130.w, 53.h)),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                            ),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  masculinColor),
                                        ),
                                        child: Text(
                                          'Masculine',
                                          style: TextStyle(
                                            color: selectedGender == "Masculine"
                                                ? Colors.white
                                                : Colors.black,
                                            fontFamily: 'Roboto',
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2575.sign,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      ElevatedButton(
                                        onPressed: () {
                                          selectGender("Female");
                                        },
                                        style: ButtonStyle(
                                          elevation:
                                              WidgetStateProperty.all<double>(
                                                  0),
                                          minimumSize: WidgetStateProperty.all(
                                              Size(130.w, 53.h)),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.r),
                                            ),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                                  femininColor),
                                        ),
                                        child: Text(
                                          'Female',
                                          style: TextStyle(
                                            color: selectedGender == "Female"
                                                ? Colors.white
                                                : Colors.black,
                                            fontFamily: 'Roboto',
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            height: 1.2575.sign,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                      visible:
                                          selectedGender.isEmpty ? true : false,
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              left: 15.0, top: 2.0),
                                          child: Text(
                                            "errorString",
                                          ))),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 50.h,
                            ),
                            MyButton(
                              buttonFunction: buttonAction,
                              buttonText: 'Continuer',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

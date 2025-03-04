import 'package:auto_route/auto_route.dart';
import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/user_form_view_model.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../../../../../models/SharedData.dart';

import '../../../../services/auth_service.dart';
import '../../../../utils/themes.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/button.dart';
import '../../../../widgets/textField.dart';

class UserFormView extends StatelessWidget {
  const UserFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final userFormViewModel = Provider.of<UserFormViewModel>(context);
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
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: OutlineBorderTextFormField(
                                labelText: "tel",
                                obscureText: false,
                                tempTextEditingController:
                                    userFormViewModel.telController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return userFormViewModel
                                      .getTempAccountValidationtel(
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
                                tempTextEditingController:
                                    userFormViewModel.nomController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return userFormViewModel
                                      .getTempAccountValidationname(
                                          textToValidate);
                                },
                                mySuffixIcon: null,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 5.h),
                              child: OutlineBorderTextFormField(
                                labelText: "Mot de passe",
                                obscureText: userFormViewModel.isPassVisible,
                                tempTextEditingController:
                                    userFormViewModel.mdpController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return userFormViewModel
                                      .getTempAccountValidationmdp(
                                          textToValidate);
                                },
                                mySuffixIcon: Container(
                                  child: InkWell(
                                    onTap: userFormViewModel
                                        .togglePasswordVisibility,
                                    child: Image(
                                      image: userFormViewModel.isPassVisible
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
                                      controller:
                                          userFormViewModel.dateController,
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
                                        userFormViewModel.date = date;
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
                                          userFormViewModel
                                              .selectGender("male");
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
                                                  userFormViewModel
                                                      .masculinColor),
                                        ),
                                        child: Text(
                                          'Masculine',
                                          style: TextStyle(
                                            color: userFormViewModel
                                                        .selectedGender ==
                                                    "Masculine"
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
                                          userFormViewModel
                                              .selectGender("female");
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
                                                  userFormViewModel
                                                      .femininColor),
                                        ),
                                        child: Text(
                                          'Female',
                                          style: TextStyle(
                                            color: userFormViewModel
                                                        .selectedGender ==
                                                    "Female"
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
                                      visible: userFormViewModel
                                              .selectedGender.isEmpty
                                          ? true
                                          : false,
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
                              height: 20.h,
                            ),
                            MyButton(
                              buttonFunction: () => userFormViewModel
                                  .buttonAction(formKey, context),
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

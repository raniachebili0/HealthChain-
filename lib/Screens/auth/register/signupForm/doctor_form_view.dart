import 'package:auto_route/auto_route.dart';
import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/doctor_form_view_model.dart';
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

class DoctorFormView extends StatefulWidget {
  const DoctorFormView({super.key});

  @override
  State<DoctorFormView> createState() => _DoctorFormViewState();
}

class _DoctorFormViewState extends State<DoctorFormView> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final doctorFormViewModel = Provider.of<DoctorFormViewModel>(context);
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
                          'If you are a doctor add your informations',
                          style: CustomTextStyle.titleStyle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Text(
                          'enter the id of your license',
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
                                labelText: "LicenseNumber",
                                obscureText: false,
                                tempTextEditingController:
                                    doctorFormViewModel.doctorIdController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return doctorFormViewModel
                                      .getTempAccountValidationDoctorId(
                                          textToValidate);
                                },
                                mySuffixIcon: null,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: OutlineBorderTextFormField(
                                labelText: "specialization",
                                obscureText: false,
                                tempTextEditingController: doctorFormViewModel
                                    .doctorspecialiteController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                validation: (textToValidate) {
                                  return doctorFormViewModel
                                      .getTempAccountValidationDoctorSpeciality(
                                          textToValidate);
                                },
                                mySuffixIcon: null,
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            MyButton(
                              buttonFunction: () => doctorFormViewModel
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

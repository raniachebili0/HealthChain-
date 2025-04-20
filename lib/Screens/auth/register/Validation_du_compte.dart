import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view_model.dart';
import 'package:health_chain/Screens/auth/register/validation_view_model.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../../../models/SharedData.dart';
import '../../../utils/colors.dart';
import '../../../utils/themes.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/errorAlert.dart';
import '../../../widgets/button.dart';
import 'package:http/http.dart' as http;

class ValidationDuCompte extends StatelessWidget {
  const ValidationDuCompte({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inscriptionViewModel = Provider.of<InscriptionViewModel>(context);
    final sharedData = Provider.of<SharedData>(context, listen: false);
    final validationViewModel = Provider.of<ValidationViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(appbartext: 'Sign Up'),
            Padding(
              padding: EdgeInsets.fromLTRB(17.w, 0.h, 17.w, 50.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 13.h),
                    child: Text(
                      'check your email account',
                      style: CustomTextStyle.titleStyle,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 28.h),
                    child: Text(
                      'On vous a envoyé un email. Entrez le code de sécurité reçu sur votre email',
                      style: CustomTextStyle.h2,
                    ),
                  ),
                  Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OtpTextField(
                          fieldWidth: 46.w,
                          fieldHeight: 50.h,
                          numberOfFields: 6,
                          enabledBorderColor: validationViewModel.hasError
                              ? AppColors.errorColor
                              : Color(0xffD8D8D8),
                          focusedBorderColor: validationViewModel.hasError
                              ? AppColors.errorColor
                              : Color(0xff0E0E0C),
                          borderRadius: BorderRadius.circular(8.r),
                          keyboardType: TextInputType.number,
                          borderWidth: 1.5,
                          textStyle: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff0e0e0c),
                          ),
                          showFieldAsBox: true,
                          onCodeChanged: (String code) {},
                          onSubmit: (String code) {
                            validationViewModel.setVerificationCode(code);
                          },
                        ),
                        SizedBox(height: 13.h),
                        InkWell(
                          onTap: () => validationViewModel.resendOtp(
                              inscriptionViewModel.emailController.text),
                          child: Text(
                            "J'ai pas reçu le code",
                            style: CustomTextStyle.lien,
                          ),
                        ),
                        SizedBox(height: 270.h),
                        MyButton(
                          buttonFunction: () {
                            print(
                                "otp:" + validationViewModel.verificationCode);
                            final validationMessage =
                                validationViewModel.validateVerificationCode(
                                    validationViewModel.verificationCode);

                            if (validationMessage != "valide") {
                              validationViewModel.setError(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(validationMessage),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } else {
                              validationViewModel.setError(false);
                              validationViewModel.verifyOtp(
                                context,
                                inscriptionViewModel.emailController.text,
                                validationViewModel.verificationCode,
                              );
                            }
                          },
                          buttonText: 'Continue',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:provider/provider.dart';
import '../../../../models/SharedData.dart';
import '../../../utils/colors.dart';
import '../../../utils/themes.dart';
import '../../../widgets/appBar.dart';
import '../../../widgets/errorAlert.dart';
import 'Mot_de_passe.dart';
import '../../../widgets/button.dart';
import 'package:http/http.dart' as http;

class ValidationDuCompte extends StatefulWidget {
  const ValidationDuCompte({Key? key}) : super(key: key);

  @override
  State<ValidationDuCompte> createState() => _ValidationDuCompteState();
}

class _ValidationDuCompteState extends State<ValidationDuCompte> {
  bool border = false;
  String verificationCode = "";

  String getTempAccountValidation(String verificationCode) {
    if (verificationCode.isEmpty) {
      return 'Please enter OTP';
    } else if (verificationCode.length != 6) {
      return 'OTP should be 6 digits long';
    }
    return "valide";
  }

  // Button action
  Future<void> buttonAction() async {
    Navigator.pushNamed(context, AppRoutes.motDePasse);
  }

  @override
  Widget build(BuildContext context) {
    final sharedData = Provider.of<SharedData>(context, listen: false);
    String tel = sharedData.telNumData ?? "000000000"; // Prevent null errors

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
                          enabledBorderColor:
                              border ? AppColors.errorColor : Color(0xffD8D8D8),
                          focusedBorderColor:
                              border ? AppColors.errorColor : Color(0xff0E0E0C),
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
                            setState(() => verificationCode = code);
                          },
                        ),
                        SizedBox(height: 13.h),
                        InkWell(
                          onTap: () {
                            print("Resend OTP tapped.");
                            // Implement resend OTP logic here
                          },
                          child: Text('J’ai pas reçu le code',
                              style: CustomTextStyle.lien),
                        ),
                        SizedBox(height: 270.h),
                        MyButton(
                            buttonFunction: buttonAction,
                            buttonText: 'Continue'),
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

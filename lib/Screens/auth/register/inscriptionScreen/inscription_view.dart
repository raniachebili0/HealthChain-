import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:provider/provider.dart';
import '../../../../../widgets/appBar.dart';
import '../../../../../widgets/textField.dart';
import 'inscription_view_model.dart';

@RoutePage()
class InscriptionScreen extends StatelessWidget {
  const InscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inscriptionViewModel = Provider.of<InscriptionViewModel>(context);
    final GlobalKey<FormState> formKeyinscr = GlobalKey<FormState>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.9,
            child: Image.asset(
              'assets/imeges/bg.jpg',
              // Make sure the image is in assets folder
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  appbartext: 'Sign Up',
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(17.w, 0.h, 17.w, 30.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 150.h,
                        child: Image.asset('assets/logo/logo.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 13.h),
                        child: Text(
                          'Welcome to HealthChain',
                          style: CustomTextStyle.titleStyle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 28.h),
                        child: Text(
                          'To register, please enter your email',
                          style: CustomTextStyle.h2,
                        ),
                      ),
                      Form(
                        key: formKeyinscr,
                        child: Column(
                          children: [
                            OutlineBorderTextFormField(
                              labelText: "Eamil",
                              obscureText: false,
                              tempTextEditingController:
                                  inscriptionViewModel.emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validation: inscriptionViewModel.validateEmail,
                              mySuffixIcon: inscriptionViewModel.valide
                                  ? Container(
                                      child: Image.asset(
                                        'assets/icons/valide.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                    )
                                  : null,
                            ),
                            SizedBox(
                              height: 135.h,
                            ),
                            MyButton(
                              buttonFunction: () => inscriptionViewModel
                                  .buttonAction(context, formKeyinscr),
                              buttonText: 'Sign Up',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 13.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('I have a HealthChaine account.',
                              style: CustomTextStyle.h4),
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: Text(
                              'Login',
                              style: CustomTextStyle.lien,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view.dart';
import 'package:health_chain/Screens/auth/register/Validation_du_compte.dart';
import 'package:health_chain/Screens/auth/register/file_picker_view.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view_model.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view_model.dart';
import 'package:health_chain/Screens/auth/register/profile_img_view.dart';
import 'package:health_chain/models/SharedData.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:health_chain/widgets/animated_widget.dart';
import 'package:provider/provider.dart';

import 'Screens/auth/register/Mot_de_passe.dart';
import 'Screens/onboarding/Onboarding.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<SharedData>(create: (_) => SharedData()),
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<InscriptionViewModel>(
          create: (context) =>
              InscriptionViewModel(context.read<AuthService>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          //  initialRoute: AppRoutes.login,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
          title: 'First Method',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: child,
        );
      },
      child: OnBoard(),
    );
  }
}

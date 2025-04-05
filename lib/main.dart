import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view.dart';
import 'package:health_chain/Screens/auth/register/Validation_du_compte.dart';
import 'package:health_chain/Screens/auth/register/signupForm/doctor_form_view_model.dart';
import 'package:health_chain/Screens/core/doctor_screens/doctor_profile_screen.dart';
import 'package:health_chain/Screens/core/doctor_screens/main_screnn_doctor.dart';
import 'package:health_chain/Screens/core/documents_screen.dart';
import 'package:health_chain/Screens/core/file_picker_view.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view_model.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view_model.dart';
import 'package:health_chain/Screens/auth/register/profile_img_view.dart';
import 'package:health_chain/Screens/auth/register/signupForm/user_form_view.dart';
import 'package:health_chain/Screens/core/home_screen.dart';
import 'package:health_chain/Screens/core/profile_screen.dart';
import 'package:health_chain/models/SharedData.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/widgets/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/auth/register/signupForm/user_form_view_model.dart';
import 'Screens/core/doctors_list_screen.dart';
import 'Screens/core/main_screen.dart';
import 'Screens/onboarding/Onboarding.dart';

int? isviewed;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
  runApp(
    MultiProvider(
      providers: [
        Provider<SharedData>(create: (_) => SharedData()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),
        ChangeNotifierProvider<MedicalRecordsService>(
          create: (_) => MedicalRecordsService(),
        ),
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<InscriptionViewModel>(
          create: (context) =>
              InscriptionViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<UserFormViewModel>(
          create: (_) => UserFormViewModel(),
        ),
        ChangeNotifierProvider<DoctorFormViewModel>(
          create: (_) => DoctorFormViewModel(),
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
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          //  initialRoute: isviewed != 0 ? AppRoutes.onboarding : AppRoutes.login,
          routes: AppRoutes.routes,
          debugShowCheckedModeBanner: false,
          title: 'First Method',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
              //      primarySwatch: Colors.blue,
              //     textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
              ),
          home: child,
        );
      },
      child: HomeScreen(),
    );
  }
}

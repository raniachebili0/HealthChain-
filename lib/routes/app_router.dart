import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view.dart';
import 'package:health_chain/Screens/auth/register/Validation_du_compte.dart';
import 'package:health_chain/Screens/core/file_picker_view.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view.dart';
import 'package:health_chain/Screens/auth/register/profile_img_view.dart';
import 'package:health_chain/Screens/onboarding/Onboarding.dart';

import '../Screens/auth/register/signupForm/user_form_view.dart';
import '../Screens/auth/register/signupForm/doctor_form_view.dart';
import '../Screens/core/documents_screen.dart';
import '../Screens/core/home_screen.dart';
import '../Screens/core/main_screen.dart';
import '../Screens/core/notification_screen.dart';
import '../Screens/core/rdv_screen.dart';

class AppRoutes {
  static const String validationDuCompte = '/validation-du-compte';
  static const String userFormView = '/user_form_view';
  static const String login = '/login_view';
  static const String inscription = '/inscription_view';
  static const String Onboarding = '/Onboarding';
  static const String filePickerScreen = '/file_picker_view';
  static const String imagePickerScreen = '/profile_img_view';
  static const String mainScreen = '/main_screen';
  static const String documentScreen = '/documents_screen';
  static const String notificationScreen = '/notification_screen';
  static const String homeScreen = '/home_screen';
  static const String srvicesScreen = '/srveces_screen';
  static const String doctorFormView = '/doctor_form_view';

  // Add more route names here

  static Map<String, WidgetBuilder> routes = {
    Onboarding: (context) => OnBoard(),
    login: (context) => LoginScreen(),
    inscription: (context) => InscriptionScreen(),
    validationDuCompte: (context) => const ValidationDuCompte(),
    userFormView: (context) => const UserFormView(),
    filePickerScreen: (context) => FilePickerScreen(),
    imagePickerScreen: (context) => ImagePickerScreen(),
    mainScreen: (context) => BottomNavBar(),
    documentScreen: (context) => DocumentsScreen(),
    notificationScreen: (context) => NotificationScreen(),
    homeScreen: (context) => HomeScreen(),
    srvicesScreen: (context) => RdvScreen(),
    doctorFormView: (context) => DoctorFormView(),

    // Add more routes here
  };
}

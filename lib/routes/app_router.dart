import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view.dart';
import 'package:health_chain/Screens/auth/register/Validation_du_compte.dart';
import 'package:health_chain/Screens/core/chat-screen.dart';
import 'package:health_chain/Screens/core/docter_detailles_screnn.dart';
import 'package:health_chain/Screens/core/doctor_screens/main_screnn_doctor.dart';
import 'package:health_chain/Screens/core/doctors_list_screen.dart';
import 'package:health_chain/Screens/core/file_liste_screen.dart';
import 'package:health_chain/Screens/core/file_picker_view.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view.dart';
import 'package:health_chain/Screens/auth/register/profile_img_view.dart';
import 'package:health_chain/Screens/onboarding/Onboarding.dart';
import 'package:health_chain/services/UserRole.dart';

import '../Screens/auth/register/signupForm/user_form_view.dart';
import '../Screens/auth/register/signupForm/doctor_form_view.dart';
import '../Screens/core/documents_screen.dart';
import '../Screens/core/home_screen.dart';
import '../Screens/core/main_screen.dart';
import '../Screens/core/notification_screen.dart';
import '../Screens/core/rdv_screen.dart';

class AppRoutes {
  static final storage = FlutterSecureStorage();

  // Route Names
  static const String validationDuCompte = '/validation-du-compte';
  static const String userFormView = '/user_form_view';
  static const String login = '/login_view';
  static const String inscription = '/inscription_view';
  static const String onboarding = '/onboarding';
  static const String filePickerScreen = '/file_picker_view';
  static const String imagePickerScreen = '/profile_img_view';
  static const String mainScreen = '/main_screen';
  static const String doctormainScreen = '/main_screnn_doctor';
  static const String documentScreen = '/documents_screen';
  static const String notificationScreen = '/notification_screen';
  static const String homeScreen = '/home_screen';
  static const String servicesScreen = '/services_screen';
  static const String doctorFormView = '/doctor_form_view';
  static const String doctorsListScreen = '/doctors_list_screen';
  static const String chatScreen = '/chat-screen';

  static Map<String, WidgetBuilder> routes = {
    onboarding: (context) => OnBoard(),
    login: (context) => LoginScreen(),
    inscription: (context) => InscriptionScreen(),
    validationDuCompte: (context) => ValidationDuCompte(),
    userFormView: (context) => UserFormView(),
    filePickerScreen: (context) => FilePickerScreen(),
    imagePickerScreen: (context) => ImagePickerScreen(),
    documentScreen: (context) => DocumentsScreen(),
    notificationScreen: (context) => NotificationScreen(),
    homeScreen: (context) => HomeScreen(),
    servicesScreen: (context) => RdvScreen(),
    doctorFormView: (context) => DoctorFormView(),
    doctorsListScreen: (context) => Doctorslistscreen(),
    mainScreen: (context) => BottomNavBar(),
    doctormainScreen: (context) => DoctorBottomNavBar(),
    chatScreen: (context) => ChatScreen(),
  };
}

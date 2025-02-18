import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view.dart';
import 'package:health_chain/Screens/auth/register/Mot_de_passe.dart';
import 'package:health_chain/Screens/auth/register/Validation_du_compte.dart';
import 'package:health_chain/Screens/auth/register/file_picker_view.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view.dart';
import 'package:health_chain/Screens/auth/register/profile_img_view.dart';
import 'package:health_chain/Screens/onboarding/Onboarding.dart';

class AppRoutes {
  static const String validationDuCompte = '/validation-du-compte';
  static const String motDePasse = '/mot-de-passe';
  static const String login = '/login_view';
  static const String inscription = '/inscription_view';
  static const String Onboarding = '/Onboarding';
  static const String filePickerScreen = '/file_picker_view';
  static const String imagePickerScreen = '/profile_img_view';

  // Add more route names here

  static Map<String, WidgetBuilder> routes = {
    Onboarding: (context) => OnBoard(),
    login: (context) => LoginScreen(),
    inscription: (context) => InscriptionScreen(),
    validationDuCompte: (context) => const ValidationDuCompte(),
    motDePasse: (context) => const MDPpage(),
    filePickerScreen: (context) => FilePickerScreen(),
    imagePickerScreen: (context) => ImagePickerScreen(),

    // Add more routes here
  };
}

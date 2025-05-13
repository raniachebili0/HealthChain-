import 'package:flutter/material.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view.dart';
import 'package:health_chain/Screens/auth/register/Validation_du_compte.dart';
import 'package:health_chain/Screens/core/chat-screen.dart';
import 'package:health_chain/Screens/core/doctor_screens/main_screnn_doctor.dart';
import 'package:health_chain/Screens/core/doctors_list_screen.dart';
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

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => OnBoard());
      case '/login_view':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/inscription_view':
        return MaterialPageRoute(builder: (_) => InscriptionScreen());
      case '/validation-du-compte':
        return MaterialPageRoute(builder: (_) => ValidationDuCompte());
      case '/user_form_view':
        return MaterialPageRoute(builder: (_) => UserFormView());
      case '/profile_img_view':
        return MaterialPageRoute(builder: (_) => ImagePickerScreen());
      case '/documents_screen':
        return MaterialPageRoute(builder: (_) => DocumentsScreen());
      case '/notification_screen':
        return MaterialPageRoute(builder: (_) => NotificationScreen());
      case '/home_screen':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/services_screen':
        return MaterialPageRoute(builder: (_) => RdvScreen());
      case '/doctor_form_view':
        return MaterialPageRoute(builder: (_) => DoctorFormView());
      case '/doctors_list_screen':
        return MaterialPageRoute(builder: (_) => Doctorslistscreen());
      case '/main_screen':
        return MaterialPageRoute(builder: (_) => BottomNavBar());
      case '/main_screnn_doctor':
        return MaterialPageRoute(builder: (_) => DoctorBottomNavBar());
      case '/chat_screen':
        return MaterialPageRoute(builder: (_) => ChatScreen());
      default:
        return _errorRoute("No route defined for ${settings.name}");
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: Center(child: Text(message)),
      ),
    );
  }
}

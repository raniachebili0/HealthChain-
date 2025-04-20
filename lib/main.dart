import 'package:flutter/material.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';
import 'views/create_role_page.dart';
import 'views/assign_role_page.dart';
import 'views/identity_verification_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Health Chain',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/create-role': (context) => const CreateRolePage(),
        '/assign-role': (context) => const AssignRolePage(),
        '/identity-verification': (context) => const IdentityVerificationPage(),
      },
    );
  }
}

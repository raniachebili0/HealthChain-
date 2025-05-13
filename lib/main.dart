import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:health_chain/Screens/auth/register/profile_img_view_model.dart';
import 'package:health_chain/Screens/auth/register/validation_view_model.dart';
import 'package:health_chain/Screens/auth/register/signupForm/user_form_view.dart';
import 'package:health_chain/Screens/core/home_screen.dart';
import 'package:health_chain/Screens/core/home_view_model.dart';
import 'package:health_chain/Screens/core/profile_screen.dart';
import 'package:health_chain/Screens/core/profile_view_model.dart';
import 'package:health_chain/models/SharedData.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/NotificationService.dart';
import 'package:health_chain/services/auth_service.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/widgets/animated_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_chain/Screens/core/file_list_view_model.dart';
import 'package:health_chain/Screens/core/file_picker_view_model.dart';
import 'package:health_chain/Screens/core/documents_view_model.dart';
import 'package:health_chain/Screens/core/doctor_details_view_model.dart';
import 'package:health_chain/Screens/core/doctors_list_view_model.dart';
import 'package:health_chain/Screens/core/doctor_profile_view_model.dart';
import 'package:health_chain/Screens/core/main_screen_doctor_view_model.dart';

import 'Screens/auth/register/signupForm/user_form_view_model.dart';
import 'Screens/core/doctors_list_screen.dart';
import 'Screens/core/main_screen.dart';
import 'Screens/onboarding/Onboarding.dart';

int? isviewed;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isviewed = prefs.getInt('onBoard');
  // Initialize Firebase first
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    return;
  }

  // Initialize the notification service
  await NotificationService.initialize();
  // Register foreground message listener

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<SharedData>(create: (_) => SharedData()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<UserService>(create: (_) => UserService()),
        ChangeNotifierProvider<MedicalRecordsService>(
          create: (_) => MedicalRecordsService(),
        ),

        // Auth ViewModels
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
        ChangeNotifierProvider<ValidationViewModel>(
          create: (context) => ValidationViewModel(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<ProfileImageViewModel>(
          create: (context) =>
              ProfileImageViewModel(context.read<AuthService>()),
        ),

        // Core ViewModels
        ChangeNotifierProvider<ProfileViewModel>(
          create: (context) => ProfileViewModel(context.read<UserService>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (context) => HomeViewModel(context.read<UserService>()),
        ),

        // Document Management ViewModels
        ChangeNotifierProvider<FileListViewModel>(
          create: (context) => FileListViewModel(
            medicalRecordsService: context.read<MedicalRecordsService>(),
            userService: context.read<UserService>(),
            category: 'all',
          ),
        ),
        ChangeNotifierProvider<FilePickerViewModel>(
          create: (context) => FilePickerViewModel(
            medicalRecordsService: context.read<MedicalRecordsService>(),
            category: 'all',
          ),
        ),
        ChangeNotifierProvider<DocumentsViewModel>(
          create: (context) => DocumentsViewModel(
            medicalRecordsService: context.read<MedicalRecordsService>(),
          ),
        ),

        // Doctor Related ViewModels
        ChangeNotifierProvider<DoctorDetailsViewModel>(
          create: (context) => DoctorDetailsViewModel(
            doctor: {},
          ),
        ),
        ChangeNotifierProvider<DoctorsListViewModel>(
          create: (context) =>
              DoctorsListViewModel(context.read<UserService>()),
        ),
        ChangeNotifierProvider<DoctorProfileViewModel>(
          create: (context) =>
              DoctorProfileViewModel(context.read<UserService>()),
        ),
        ChangeNotifierProvider<MainScreenDoctorViewModel>(
          create: (context) =>
              MainScreenDoctorViewModel(context.read<UserService>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Set up the foreground message handler
    NotificationService.setupForegroundMessageHandler();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          initialRoute: '/onboarding',
          onGenerateRoute: AppRouter.generateRoute,
          debugShowCheckedModeBanner: false,
          title: 'First Method',
          theme: ThemeData(),
          home: child,
        );
      },
      //  child: LoginScreen(),
    );
  }
}

///////////////////////////////////***************************/////////////////////////////

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Initialize Firebase first
//   try {
//     await Firebase.initializeApp();
//     print('Firebase initialized successfully');
//   } catch (e) {
//     print('Error initializing Firebase: $e');
//     return;
//   }
//
//   // Initialize the notification service
//   await NotificationService.initialize();
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   String? _fcmToken;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Set up the foreground message handler
//     NotificationService.setupForegroundMessageHandler();
//
//     // Get the FCM token
//     _getFCMToken();
//   }
//
//   Future<void> _getFCMToken() async {
//     String? token = await NotificationService.getFCMToken();
//     if (token != null) {
//       setState(() {
//         _fcmToken = token;
//       });
//       print('FCM Token: $token');
//     } else {
//       setState(() {
//         _errorMessage = 'No FCM token available';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('FCM Token Generator')),
//         body: Column(
//           children: [
//             Center(
//               child: _errorMessage != null
//                   ? Text(_errorMessage!)
//                   : _fcmToken != null
//                       ? SelectableText('FCM Token: $_fcmToken')
//                       : const Text('Generating FCM Token...'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_fcmToken != null) {
//                   NotificationService.sendNotificationToServer(
//                     tokens: [_fcmToken!],
//                     title: 'Hello from Flutter',
//                     body: 'This is a test push notification',
//                   );
//                 }
//               },
//               child: const Text('Send Test Notification'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

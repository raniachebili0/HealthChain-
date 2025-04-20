import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/doctor_screens/consultation_screen.dart';
import 'package:health_chain/Screens/core/doctor_screens/doctor_profile_screen.dart';
import 'package:health_chain/Screens/core/doctor_screens/getion_document_screnn.dart';
import 'package:health_chain/Screens/core/doctor_screens/rdv_doctor_screen.dart';
import 'package:health_chain/Screens/core/profile_screen.dart';
import 'package:health_chain/Screens/core/rdv_screen.dart';
import 'package:health_chain/utils/colors.dart';

class DoctorBottomNavBar extends StatefulWidget {
  const DoctorBottomNavBar({super.key});

  @override
  _DoctorBottomNavBarState createState() => _DoctorBottomNavBarState();
}

class _DoctorBottomNavBarState extends State<DoctorBottomNavBar> {
  int page = 0;

  static List<Widget> PagesAll = <Widget>[
    RdvDoctorScreen(),
    GetionDocumentScrenn(),
    ConsultationScreen(),
    DoctorProfileScreen(),
  ];

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 60.0,
        items: <Widget>[
          Image.asset('assets/icons/accueil.png', width: 25, height: 25),
          Image.asset('assets/icons/document.png', width: 25, height: 25),
          Image.asset('assets/icons/bulle.png', width: 25, height: 25),
          Image.asset('assets/icons/utilisateur.png', width: 25, height: 25),
        ],
        color: AppColors.primaryColor,
        buttonBackgroundColor: AppColors.primaryColor,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: PagesAll[page],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/documents_screen.dart';
import 'package:health_chain/Screens/core/home_screen.dart';
import 'package:health_chain/Screens/core/profile_screen.dart';
import 'package:health_chain/Screens/core/rdv_screen.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/colors.dart';

import 'convesations_screen.dart';
import 'notification_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int page = 0;

  static List<Widget> PagesAll = <Widget>[
    HomeScreen(),
    DocumentsScreen(),
    RdvScreen(),
    ConvesationsScreen(),
    ProfileScreen(),
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
          Image.asset('assets/icons/calendrier.png', width: 25, height: 25),
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

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/profile_screen.dart';
import 'package:health_chain/Screens/core/rdv_screen.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/Screens/core/home_screen.dart';
import 'package:health_chain/Screens/core/documents_screen.dart';
import 'package:health_chain/Screens/core/convesations_screen.dart';

class PractitionerBottomNavBar extends StatefulWidget {
  const PractitionerBottomNavBar({super.key});

  @override
  _PractitionerBottomNavBarState createState() => _PractitionerBottomNavBarState();
}

class _PractitionerBottomNavBarState extends State<PractitionerBottomNavBar> {
  int page = 0;

  // List of screens for practitioners
  static List<Widget> PagesAll = <Widget>[
    HomeScreen(), // Home screen
    DocumentsScreen(), // Documents screen
    RdvScreen(), // Appointments screen
    ConvesationsScreen(), // Conversations screen
    ProfileScreen(), // Profile screen
  ];

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 30,
                  icon: Icon(Icons.notifications_rounded),
                  color: Color(0xD25B5B5B),
                  onPressed: () {},
                )
              ]
            ),
          ),
        ],
        title: Text(
          'HealthChain - Practitioner',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 30.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
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
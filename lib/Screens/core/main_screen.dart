import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:health_chain/Screens/core/srveces_screen.dart';
import 'package:health_chain/utils/colors.dart';

import 'home_screen.dart';
import 'documents_screen.dart';
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
    ServicesScreen(),
    NotificationScreen()
  ];

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 60.0,
        items: <Widget>[
          Image.asset('assets/icons/home.png', width: 30, height: 30),
          Image.asset('assets/icons/folder.png', width: 30, height: 30),
          Image.asset('assets/icons/mallette.png', width: 30, height: 30),
          Image.asset('assets/icons/notification.png', width: 30, height: 30),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/auth/loginScreen/login_view.dart';
import 'package:health_chain/Screens/auth/register/inscriptionScreen/inscription_view.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/onbardingModel.dart';

class OnBoard extends StatefulWidget {
  @override
  _OnBoardState createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  int currentIndex = 0;
  late PageController _pageController;
  List<OnboardModel> screens = <OnboardModel>[
    OnboardModel(
      img: 'assets/animations/Animation1.json',
      text: "Find a lot of specialist doctors in one place ",
      bg: Colors.white,
      button: Color(0xFF014886),
      type: 'welcome',
    ),
    OnboardModel(
      img: 'assets/animations/Animation2.json',
      text: "Get connect our Online medical services for you 24 hours",
      bg: Color(0xFF014886),
      button: Colors.white,
      type: 'welcome',
    ),
    OnboardModel(
      img: 'assets/animations/Animation3.json',
      text:
          "Create your digital medical record and centralize all your documents",
      bg: Colors.white,
      button: Color(0xFF014886),
      type: 'welcome',
    ),
    OnboardModel(
      img: 'assets/logo/logo.png',
      text:
          "Create your digital medical record and centralize all your documents",
      bg: Colors.white,
      button: Color(0xFF014886),
      type: 'start',
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _storeOnboardInfo() async {
    print("Shared pref called");
    int isViewed = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
    print(prefs.getInt('onBoard'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView.builder(
            itemCount: screens.length,
            controller: _pageController,
            physics: BouncingScrollPhysics(),
            //NeverScrollableScrollPhysics(),
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, index) {
              final screen = screens[index];

              switch (screen.type) {
                case "welcome":
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _storeOnboardInfo();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textInputColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                          height: 300.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(60),
                                bottomRight: Radius.circular(60)),
                          ),
                          child: LottieBuilder.asset(screens[index].img)),
                      Padding(
                        padding: const EdgeInsets.all(30),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryColor.withOpacity(0.4),
                                //  Color(0xFFF5F7FF),
                                Colors.white
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter, // End position
                            ),
                            borderRadius: BorderRadius.circular(
                                20), // Optional: Rounded corners
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.h, vertical: 20.w),
                            child: Column(
                              children: [
                                Text(
                                  screens[index].text,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: AppColors.block,
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 10.0,
                                      child: ListView.builder(
                                        itemCount: screens.length - 1,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 3.0),
                                                  width: 12.5,
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    color: currentIndex == index
                                                        ? AppColors.primaryColor
                                                        : AppColors
                                                            .textInputColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ]);
                                        },
                                      ),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () async {
                                        // print(index);
                                        // if (index == screens.length - 1) {
                                        //   await _storeOnboardInfo();
                                        //   Navigator.pushReplacement(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //           builder: (context) =>
                                        //               LoginScreen()));
                                        // }

                                        _pageController.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.arrow_forward_sharp,
                                                color: Colors.white,
                                              )
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                case "start":
                  return Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            height: 200.h,
                            child: Image.asset(screens[index].img)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.h, vertical: 40.w),
                          child: Column(
                            children: [
                              Text(
                                "Let’s get started!",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                  color: AppColors.block,
                                ),
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                              Text(
                                "Create you Account to enjoy the features we’ve provided, and stay healthy!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: 'Poppins',
                                  color: AppColors.textInputColor,
                                ),
                              ),
                              SizedBox(
                                height: 120.h,
                              ),
                              MyButton(
                                buttonFunction: () async {
                                  await _storeOnboardInfo();
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              InscriptionScreen()));
                                },
                                buttonText: 'Start',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
              }
            }),
      ),
    );
  }
}

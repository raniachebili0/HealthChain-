import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h, bottom: 90.h),
          child: Column(
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: userService.getuserbyid(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No user data found"));
                  } else {
                    final user = snapshot.data!;
                    print("userrrrrrrr ${user}");
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ClipOval(
                          child: user['photo'] != null &&
                                  user['photo'].startsWith("http")
                              ? Image.network(
                                  user['photo'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey.shade400,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/Landing.png',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Text(
                          user['name'] ?? "User Name",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user['email'] ?? "User Email",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black45,
                              ),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Text(
                              user['telecom'] ?? "User tel",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProfileItem(
                        text: "Wallet",
                        imagePath: "assets/icons/bulle.png",
                        icon: Icons.navigate_next_outlined,
                        onTap: () {
                          print("Wallet clicked");
                        }, // Fix applied here
                      ),
                      ProfileItem(
                        text: "Settings",
                        imagePath: "assets/icons/home.png",
                        icon: Icons.navigate_next_outlined,
                        onTap: () {
                          print("Wallet clicked");
                        }, // Fix applied here
                      ),
                      ProfileItem(
                        text: "Profile",
                        imagePath: "assets/icons/bulle.png",
                        icon: Icons.navigate_next_outlined,
                        onTap: () {
                          print("Wallet clicked");
                        }, // Fix applied here
                      ),
                      ProfileItem(
                        text: "LogOut",
                        imagePath: "assets/icons/bulle.png",
                        icon: Icons.logout,
                        onTap: () async {
                          // Show an AlertDialog to confirm the action
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Logout'),
                                content:
                                    Text('Are you sure you want to log out?'),
                                actions: <Widget>[
                                  // Cancel button
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  // Confirm button
                                  TextButton(
                                    onPressed: () async {
                                      // Perform the logout actions
                                      await storage.delete(key: "auth_token");
                                      await storage.delete(key: "user_role");
                                      Navigator.pushReplacementNamed(
                                          context, AppRoutes.login);
                                    },
                                    child: Text('Confirm'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
// Fix applied here
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String text;
  final String imagePath;
  final IconData icon;
  final VoidCallback onTap; // Dynamic onTap function

  const ProfileItem({
    super.key,
    required this.text,
    required this.imagePath,
    required this.icon,
    required this.onTap, // Make onTap required
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call the dynamic function
      child: Container(
        height: 80.h, // Ensure the item has a height so it is clickable
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3F1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Image.asset(
                imagePath,
                width: 20.w,
                height: 20.h,
              ),
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              size: 35,
              color: const Color(0xFF555555),
            ),
          ],
        ),
      ),
    );
  }
}

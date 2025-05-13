import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/profile_view_model.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(left: 40.w, right: 40.w, top: 20.h, bottom: 70.h),
          child: Column(
            children: [
              if (profileViewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (profileViewModel.error != null)
                Center(child: Text("Error: ${profileViewModel.error}"))
              else if (profileViewModel.userData == null ||
                  profileViewModel.userData!.isEmpty)
                const Center(child: Text("No user data found"))
              else
                _buildUserInfo(profileViewModel.userData!),
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
                        onTap: profileViewModel.navigateToWallet,
                      ),
                      ProfileItem(
                        text: "Settings",
                        imagePath: "assets/icons/home.png",
                        icon: Icons.navigate_next_outlined,
                        onTap: profileViewModel.navigateToSettings,
                      ),
                      ProfileItem(
                        text: "Profile",
                        imagePath: "assets/icons/bulle.png",
                        icon: Icons.navigate_next_outlined,
                        onTap: profileViewModel.navigateToProfile,
                      ),
                      ProfileItem(
                        text: "LogOut",
                        imagePath: "assets/icons/bulle.png",
                        icon: Icons.logout,
                        onTap: () => _showLogoutDialog(context),
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

  Widget _buildUserInfo(Map<String, dynamic> user) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ClipOval(
          child: user['photo'] != null && user['photo'].startsWith("http")
              ? Image.network(
                  user['photo'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
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
          style: const TextStyle(
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              user['telecom'] ?? "User tel",
              style: const TextStyle(
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await context.read<ProfileViewModel>().logout(context);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login_view');
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String text;
  final String imagePath;
  final IconData icon;
  final VoidCallback onTap;

  const ProfileItem({
    super.key,
    required this.text,
    required this.imagePath,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80.h,
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

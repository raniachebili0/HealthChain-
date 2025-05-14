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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
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
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildProfileSection(
                      title: "Account",
                      items: [
                        ProfileItem(
                          text: "Edit Profile",
                          icon: Icons.person_outline,
                          onTap: profileViewModel.navigateToProfile,
                          color: Colors.blue,
                        ),
                        ProfileItem(
                          text: "Wallet",
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: profileViewModel.navigateToWallet,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _buildProfileSection(
                      title: "Settings",
                      items: [
                        ProfileItem(
                          text: "Settings",
                          icon: Icons.settings_outlined,
                          onTap: profileViewModel.navigateToSettings,
                          color: Colors.orange,
                        ),
                        ProfileItem(
                          text: "Notifications",
                          icon: Icons.notifications_outlined,
                          onTap: () {},
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    _buildProfileSection(
                      title: "Support",
                      items: [
                        ProfileItem(
                          text: "Help Center",
                          icon: Icons.help_outline,
                          onTap: () {},
                          color: Colors.teal,
                        ),
                        ProfileItem(
                          text: "Logout",
                          icon: Icons.logout,
                          onTap: () => _showLogoutDialog(context),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<ProfileItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> user) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: user['photo'] != null && user['photo'].startsWith("http")
                    ? Image.network(
                        user['photo'],
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 60.w,
                          color: Colors.grey.shade400,
                        ),
                      )
                    : Image.asset(
                        'assets/images/Landing.png',
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          user['name'] ?? "User Name",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.email_outlined,
              size: 16.w,
              color: Colors.grey[600],
            ),
            SizedBox(width: 5.w),
            Text(
              user['email'] ?? "User Email",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_outlined,
              size: 16.w,
              color: Colors.grey[600],
            ),
            SizedBox(width: 5.w),
            Text(
              user['telecom'] ?? "User tel",
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10.w),
              const Text('Confirm Logout'),
            ],
          ),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<ProfileViewModel>().logout(context);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login_view');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProfileItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const ProfileItem({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.w,
              ),
            ),
            SizedBox(width: 15.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

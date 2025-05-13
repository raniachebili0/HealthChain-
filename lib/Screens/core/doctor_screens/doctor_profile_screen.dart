import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/Screens/core/profile_screen.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/appBar.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final UserService userService = UserService();
  bool isEditing = false;
  final storage = FlutterSecureStorage();

  // Controller to handle text field input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telecomController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController schedulesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(appbartext: 'Doctor Profile'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Show an AlertDialog to confirm the action
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Logout'),
                            content: Text('Are you sure you want to log out?'),
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
                                      context, '/login_view');
                                },
                                child: Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Icon(Icons.logout),
                  ),
                ],
              ),
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
                    print("userrrrrrrr $user");
                    // Initializing controllers with user data
                    nameController.text = user['name'] ?? '';
                    emailController.text = user['email'] ?? '';
                    telecomController.text = user['telecom'] ?? '';
                    bioController.text = user['doctorbio'] ?? '';
                    addressController.text = user['address'] ?? '';
                    schedulesController.text = user['doctorhoraire'] ?? '';

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 170.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: 100.h,
                                width: 100.w,
                                child: user['photo'] != null &&
                                        user['photo'].startsWith("http")
                                    ? Image.network(
                                        user['photo'],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
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
                                  Icon(Icons.email),
                                  Text(
                                    user['email'] ?? "User Email",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  Icon(Icons.phone),
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
                          ),
                        ),
                        // Editable fields when editing
                        isEditing
                            ? Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                          labelText: 'Name',
                                          border: OutlineInputBorder()),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder()),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: telecomController,
                                      decoration: InputDecoration(
                                          labelText: 'Phone',
                                          border: OutlineInputBorder()),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: bioController,
                                      decoration: InputDecoration(
                                          labelText: 'Bio',
                                          border: OutlineInputBorder()),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: addressController,
                                      decoration: InputDecoration(
                                          labelText: 'Address',
                                          border: OutlineInputBorder()),
                                    ),
                                    SizedBox(height: 10),
                                    TextField(
                                      controller: schedulesController,
                                      decoration: InputDecoration(
                                          labelText: 'Schedules',
                                          border: OutlineInputBorder()),
                                    ),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final updateData = {
                                          'name': nameController.text,
                                          'email': emailController.text,
                                          'telecom': telecomController.text,
                                          'doctorbio': bioController.text,
                                          'address': addressController.text,
                                          'doctorhoraire':
                                              schedulesController.text,
                                        };

                                        bool success = await userService
                                            .updateUserProfile(updateData);

                                        if (success) {
                                          setState(() {
                                            isEditing =
                                                false; // Stop editing after saving
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Profile updated successfully')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to update profile')),
                                          );
                                        }
                                      },
                                      child: Text('Save Changes'),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  // Profile data display when not editing
                                  buildProfileSection(
                                      'Bio', user['doctorbio'] ?? "Doctor bio"),
                                  buildProfileSection('Address',
                                      user['address'] ?? "Doctor address"),
                                  buildProfileSection(
                                      'Schedules',
                                      user['doctorhoraire'] ??
                                          "Doctor schedules"),
                                  // Button to toggle editing mode
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isEditing = true;
                                      });
                                    },
                                    child: Text('Edit Profile'),
                                  ),
                                ],
                              ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build profile sections
  Widget buildProfileSection(String title, String value) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      width: double.infinity,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black45,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

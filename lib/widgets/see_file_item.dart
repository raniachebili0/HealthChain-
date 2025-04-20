import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/file_liste_screen.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:http/http.dart' as http;

class DoctorSeeFileCard extends StatelessWidget {
  final String filetitle;
  final String user;
  final String startdateaccess;
  final String enddateaccess;
  final String fileurl;
  final String fileid;

  const DoctorSeeFileCard({
    super.key,
    required this.filetitle,
    required this.user,
    required this.startdateaccess,
    required this.fileurl,
    required this.fileid,
    required this.enddateaccess,
  });

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.file_present_rounded,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      filetitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    DateTime now = DateTime.now();
                    DateTime startDate = DateTime.parse(startdateaccess);
                    DateTime endDate = DateTime.parse(enddateaccess);
                    if (now.isAfter(startDate) && now.isBefore(endDate)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SfPdfViewerPage(url: fileurl),
                        ),
                      );
                    } else {
                      // If current time is outside the access interval, show an alert.
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Access Denied"),
                            content: Text(
                                "Sorry, this file is no longer accessible at this time."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Close the alert dialog
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    final userData = await userService.getuserbyidinfo(
                        user); // assuming user is a userId string

                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text('User Information'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${userData['name']}'),
                                Text('Email: ${userData['email']}'),
                                Text('Phone: ${userData['telecom']}'),
                                Text('Address: ${userData['address']}'),
                                // Add other fields as needed
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: () async {
                    final descriptionController = TextEditingController();

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Add prescription'),
                          content: TextField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                                hintText: 'Enter file prescription'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final description =
                                    descriptionController.text.trim();
                                if (description.isNotEmpty) {
                                  final accessFileId =
                                      fileid; // replace or pass dynamically
                                  final response = await http.patch(
                                    Uri.parse(
                                        'http://10.0.2.2:3000/medical-records/$accessFileId/description'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      // 'Authorization': 'Bearer your_token', // if needed
                                    },
                                    body: jsonEncode(
                                        {'description': description}),
                                  );

                                  if (response.statusCode == 200) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Description updated successfully')),
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to update description')),
                                    );
                                  }
                                }
                              },
                              child: Text('Save'),
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
                  child: Text(
                    'prescription',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

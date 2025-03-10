import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/FileCategoryCard.dart';
import 'package:health_chain/widgets/see_file_item.dart';

class FileListeScreen extends StatelessWidget {
  final String category;

  const FileListeScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.notifications_rounded),
                color: Color(0xD25B5B5B),
                onPressed: () {},
              )
            ]),
          ),
        ],
        title: Text(
          'HealthChaine',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 30.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                controller: null,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Color(0xFF949393)),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Color(0xFFCBE0F3),
                ),
                onChanged: (value) {
                  // Handle search text changes
                },
              ),
              FileCategoryCard(
                title: "file name",
                uploudDate: "5/15/2025",
                // You can replace this with a custom image
                onMorePressed: () {
                  print("More options clicked");
                },
              ),
              FileCategoryCard(
                title: "file name",
                uploudDate: "17/08/2025",
                // You can replace this with a custom image
                onMorePressed: () {
                  print("More options clicked");
                },
              ),
              FileCategoryCard(
                title: "file name",
                uploudDate: "02/5/2025",
                // You can replace this with a custom image
                onMorePressed: () {
                  print("More options clicked");
                },
              ),

              // FutureBuilder<List<Map<String, dynamic>>>(
              //   future: ************,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasError) {
              //       return Center(child: Text("Error: ${snapshot.error}"));
              //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //       return Center(child: Text("No doctors found"));
              //     } else {
              //       final files = snapshot.data!;
              //       return Expanded(
              //         child: ListView.builder(
              //           scrollDirection: Axis.vertical,
              //           itemCount: files.length,
              //           itemBuilder: (context, index) {
              //             final file = files[index];
              //             return FileCategoryCard(doctor: files);
              //           },
              //         ),
              //       );
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.filePickerScreen);
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}

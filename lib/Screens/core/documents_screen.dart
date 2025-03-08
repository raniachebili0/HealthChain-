import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/widgets/FolderCategoryCard.dart';
import 'package:health_chain/widgets/appBar.dart';

import '../../utils/colors.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Map<String, dynamic>> FileCategoryItems = [
    {
      "titre": "allergy-intolerance",
      "itemNb": "5",
      "onTap": (BuildContext context) {
        Navigator.pushNamed(context, AppRoutes.fileListeScreen);
      },
    },
    {
      "titre": "diagnostic-report",
      "itemNb": "5",
      "onTap": () {},
    },
    {
      "titre": "imaging-study",
      "itemNb": "5",
      "onTap": () {},
    },
    {
      "titre": "medication-request",
      "itemNb": "5",
      "onTap": () {},
    },
    {
      "titre": "observation",
      "itemNb": "5",
      "onTap": () {},
    },
    {
      "titre": "procedure",
      "itemNb": "5",
      "onTap": () {},
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.h),
                margin: EdgeInsets.symmetric(vertical: 30.w),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Record',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Create your digital \nmedical record and \ncentralize all your \ndocuments.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 110,
                child: Image.asset(
                  'assets/imeges/doc.png',
                  // Add a geometric pattern image
                  width: 300.w,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          Expanded(
              child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1, // Adjusts the width/height ratio
            ),
            itemCount: FileCategoryItems.length,
            itemBuilder: (context, index) {
              final item = FileCategoryItems[index];
              return FolderCategoryCard(
                title: item['titre'],
                fileCount: item['itemNb'],
                // You can replace this with a custom image
                onMorePressed: () {
                  if (item['onTap'] != null) {
                    item['onTap'](context); // Pass context correctly
                  }
                },
              );
            },
          )
              // ListView.builder(
              //   scrollDirection: Axis.vertical,
              //   itemCount: FileCategoryItems.length,
              //   itemBuilder: (context, index) {
              //     final item = FileCategoryItems[index];
              //     return FileCategoryCard(
              //       title: item['titre'],
              //       fileCount: item['itemNb'],
              //       // You can replace this with a custom image
              //       onMorePressed: () {
              //         item['onTap'];
              //       },
              //     );
              //   },
              // ),
              ),
        ],
      ),
    )));
  }
}

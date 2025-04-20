import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/file_liste_screen.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:health_chain/widgets/FolderCategoryCard.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  Map<String, int> fileCounts = {
    "allergy-intolerance": 0,
    "diagnostic-report": 0,
    "imaging-study": 0,
    "medication-request": 0,
    "observation": 0,
    "procedure": 0,
  };

  @override
  void initState() {
    super.initState();
    // Refresh file listings when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshAllCategories();
    });
  }

  Future<void> refreshAllCategories() async {
    final documentService = Provider.of<MedicalRecordsService>(context, listen: false);
    await documentService.refreshAllCategories();
    updateFileCounts();
  }

  void updateFileCounts() async {
    final documentService = Provider.of<MedicalRecordsService>(context, listen: false);
    
    // Update the count for each category
    for (String category in fileCounts.keys) {
      try {
        final files = await documentService.getFilesList(category);
        setState(() {
          fileCounts[category] = files.length;
        });
      } catch (e) {
        print("Error getting count for $category: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create the folder items with updated counts
    final List<Map<String, dynamic>> folderCategoryItems = [
      {
        "titre": "allergy-intolerance",
        "itemNb": "${fileCounts["allergy-intolerance"]} files",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FileListeScreen(category: "allergy-intolerance"),
            ),
          );
        },
      },
      {
        "titre": "diagnostic-report",
        "itemNb": "${fileCounts["diagnostic-report"]} files",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FileListeScreen(category: "diagnostic-report"),
            ),
          );
        },
      },
      {
        "titre": "imaging-study",
        "itemNb": "${fileCounts["imaging-study"]} files",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileListeScreen(category: "imaging-study"),
            ),
          );
        },
      },
      {
        "titre": "medication-request",
        "itemNb": "${fileCounts["medication-request"]} files",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  FileListeScreen(category: "medication-request"),
            ),
          );
        },
      },
      {
        "titre": "observation",
        "itemNb": "${fileCounts["observation"]} files",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileListeScreen(category: "observation"),
            ),
          );
        },
      },
      {
        "titre": "procedure",
        "itemNb": "${fileCounts["procedure"]} files",
        "onTap": (BuildContext context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileListeScreen(category: "procedure"),
            ),
          );
        },
      },
    ];

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
              child: RefreshIndicator(
                onRefresh: refreshAllCategories,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1, // Adjusts the width/height ratio
                  ),
                  itemCount: folderCategoryItems.length,
                  itemBuilder: (context, index) {
                    final item = folderCategoryItems[index];
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
                ),
              )
          ),
        ],
      ),
    )));
  }
}

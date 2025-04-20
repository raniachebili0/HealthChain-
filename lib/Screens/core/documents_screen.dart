import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:health_chain/Screens/core/documents_view_model.dart';
import 'package:health_chain/Screens/core/file_liste_screen.dart';
import 'package:health_chain/widgets/FolderCategoryCard.dart';

import '../../utils/colors.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentsViewModel(
        medicalRecordsService: context.read<MedicalRecordsService>(),
      ),
      child: _DocumentsView(),
    );
  }
}

class _DocumentsView extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      "titre": "allergy-intolerance",
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DocumentsViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    margin: const EdgeInsets.symmetric(vertical: 30),
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
                        const Text(
                          'Medical Record',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create your digital \nmedical record and \ncentralize all your \ndocuments.',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 110,
                    child: Image.asset(
                      'assets/imeges/doc.png',
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              if (viewModel.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    viewModel.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    return FolderCategoryCard(
                      title: item['titre'],
                      fileCount: viewModel.getFileCount(item['titre']).toString(),
                      onMorePressed: () {
                        if (item['onTap'] != null) {
                          item['onTap'](context);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

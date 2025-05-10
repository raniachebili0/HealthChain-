import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/utils/themes.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/widgets/appBar.dart';
import 'package:health_chain/widgets/button.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:health_chain/Screens/core/file_picker_view_model.dart';

class FilePickerScreen extends StatelessWidget {
  final String category;
  final VoidCallback? onFileUploaded;

  const FilePickerScreen({
    Key? key,
    required this.category,
    this.onFileUploaded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilePickerViewModel(
        medicalRecordsService: context.read<MedicalRecordsService>(),
        category: category,
      ),
      child: _FilePickerView(onFileUploaded: onFileUploaded),
    );
  }
}

class _FilePickerView extends StatelessWidget {
  final VoidCallback? onFileUploaded;

  const _FilePickerView({this.onFileUploaded});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FilePickerViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(appbartext: 'Upload File'),
            Padding(
              padding: const EdgeInsets.fromLTRB(17.0, 0.0, 17.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 13),
                    child: Text(
                      'Hi patient, Add your document',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 28),
                    child: Text(
                      "Securely upload and manage your medical records for easy access anytime.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (viewModel.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        viewModel.error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  SizedBox(
                    height: 300,
                    child: viewModel.hasSelectedFile
                        ? (viewModel.pdfController != null
                            ? PdfView(controller: viewModel.pdfController!)
                            : _buildFilePreview(viewModel.selectedFilePath!))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: IconButton(
                                onPressed: viewModel.pickFile,
                                icon: const Icon(Icons.file_open_rounded),
                                tooltip: "Pick File",
                                iconSize: 70,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 120),
                  MyButton(
                    buttonFunction: () async {
                      if (viewModel.hasSelectedFile) {
                        final result = await viewModel.uploadFile();
                        if (context.mounted) {
                          if (result == 'success') {
                            if (onFileUploaded != null) {
                              onFileUploaded!();
                            }
                            Navigator.pop(context);
                          } else if (result == 'invalid_type') {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Invalid File Type'),
                                content:
                                    const Text('Upload a valid file category.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      }
                    },
                    buttonText: viewModel.isLoading ? 'Uploading...' : 'Upload',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(String filePath) {
    final fileExtension = filePath.split('.').last.toLowerCase();

    if (fileExtension == 'jpg' ||
        fileExtension == 'jpeg' ||
        fileExtension == 'png') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(filePath),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file,
                size: 70,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 10),
              Text(
                'Selected file: ${filePath.split('/').last}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }
}

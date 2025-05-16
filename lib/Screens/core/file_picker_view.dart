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
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(appbartext: 'Upload File'),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add your document',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Securely upload and manage your medical records for easy access anytime.",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      if (viewModel.error != null)
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: theme.colorScheme.error),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  viewModel.error!,
                                  style:
                                      TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: 24.h),
                      Container(
                        height: 300.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: viewModel.hasSelectedFile
                            ? (viewModel.pdfController != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: PdfView(
                                        controller: viewModel.pdfController!),
                                  )
                                : _buildFilePreview(
                                    viewModel.selectedFilePath!))
                            : _buildUploadArea(viewModel),
                      ),
                      SizedBox(height: 32.h),
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
                                    content: const Text(
                                        'Please upload a valid file category.'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
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
                        buttonText:
                            viewModel.isLoading ? 'Uploading...' : 'Upload',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea(FilePickerViewModel viewModel) {
    return InkWell(
      onTap: viewModel.pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Click to select a file',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'or drag and drop your file here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(filePath),
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insert_drive_file,
                size: 48,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Text(
              filePath.split('/').last,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'File selected',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
  }
}

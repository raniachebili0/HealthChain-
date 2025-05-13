import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_chain/Screens/core/file_picker_view.dart';
import 'package:health_chain/routes/app_router.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:health_chain/services/user_service.dart';
import 'package:health_chain/utils/colors.dart';
import 'package:health_chain/widgets/FileCategoryCard.dart';
import 'package:health_chain/widgets/see_file_item.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:health_chain/Screens/core/file_list_view_model.dart';

import '../../services/document_service.dart';

class FileListeScreen extends StatelessWidget {
  final String category;

  const FileListeScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FileListViewModel(
        medicalRecordsService: context.read<MedicalRecordsService>(),
        userService: context.read<UserService>(),
        category: category,
      ),
      child: _FileListView(category: category),
    );
  }
}

class _FileListView extends StatelessWidget {
  final String category;

  const _FileListView({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FileListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/notification_screen');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: viewModel.setSearchQuery,
              ),
              const SizedBox(height: 16),
              if (viewModel.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    viewModel.error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Expanded(
                child: StreamBuilder<List<dynamic>>(
                  stream: viewModel.filesStream,
                  builder: (context, snapshot) {
                    if (viewModel.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No files found.'));
                    }

                    final files = snapshot.data!;
                    final searchQuery = viewModel.searchQuery.toLowerCase();
                    final filteredFiles = searchQuery.isEmpty
                        ? files
                        : files
                            .where((file) => file['fileName']
                                .toString()
                                .toLowerCase()
                                .contains(searchQuery))
                            .toList();

                    return ListView.builder(
                      itemCount: filteredFiles.length,
                      itemBuilder: (context, index) {
                        final file = filteredFiles[index];
                        return FileCategoryCard(
                          title: file['fileName'] ?? 'Unnamed File',
                          uploudDate: file['uplodeDate'] ?? 'No creation date',
                          onMorePressed: () => _showFileActions(context, file),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilePickerScreen(
                category: category,
                onFileUploaded: () {
                  // Refresh the files list when returning from the file picker screen
                  viewModel.loadFiles();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFileActions(BuildContext context, dynamic file) {
    final viewModel = context.read<FileListViewModel>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('View File'),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SfPdfViewerPage(url: file['fileUrl']),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Give file access'),
                onTap: () async {
                  final doctors = await viewModel.getAllDoctors();
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AccessFileFormDialog(
                          doctors: doctors,
                          fileName: file['fileName'],
                          fileUrl: file['fileUrl'],
                        );
                      },
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete File'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, dynamic file) {
    final viewModel = context.read<FileListViewModel>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content:
              Text('Are you sure you want to delete "${file['fileName']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
                viewModel.deleteFile(file['_id'], file['fileType']);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class SfPdfViewerPage extends StatelessWidget {
  final String url;

  const SfPdfViewerPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview")),
      body: SfPdfViewer.network(url),
    );
  }
}

class AccessFileFormDialog extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final List doctors;

  const AccessFileFormDialog({
    super.key,
    required this.fileUrl,
    required this.fileName,
    required this.doctors,
  });

  @override
  _AccessFileFormDialogState createState() => _AccessFileFormDialogState();
}

class _AccessFileFormDialogState extends State<AccessFileFormDialog> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDoctorId;
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final medicalRecordsService =
        Provider.of<MedicalRecordsService>(context, listen: false);
    return AlertDialog(
      title: Text('Give Access to File'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('File: ${widget.fileName}'),
              SizedBox(height: 10),

              // Doctor Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Choose Doctor'),
                value: selectedDoctorId,
                items: widget.doctors.map((doctor) {
                  return DropdownMenuItem<String>(
                    value: doctor['_id'],
                    child: Text(doctor['name'] ?? ''),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedDoctorId = val;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a doctor' : null,
              ),

              SizedBox(height: 12),

              // Start Date
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                    );

                    if (pickedTime != null) {
                      final combined = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() => startDate = combined);
                    }
                  }
                },
                child: Text(
                  startDate != null
                      ? 'Start: ${startDate!.toLocal()}'
                      : 'Select Start Date & Time',
                ),
              ),

              // End Date
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                    );

                    if (pickedTime != null) {
                      final combined = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() => endDate = combined);
                    }
                  }
                },
                child: Text(
                  endDate != null
                      ? 'End: ${endDate!.toLocal()}'
                      : 'Select End Date & Time',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;

            // Prepare your data object
            final accessFile = {
              'fileUrl': widget.fileUrl,
              'fileName': widget.fileName,
              'DebuitAccessDate': startDate?.toIso8601String(),
              'FinAccessDate': endDate?.toIso8601String(),
              'doctor': selectedDoctorId,
              // 'patient': currentPatientId (set based on app state)
            };

            print("Access File Submitted: $accessFile");

            final medicalRecordsService =
                Provider.of<MedicalRecordsService>(context, listen: false);
            medicalRecordsService.createAccessFile(
              fileName: widget.fileName,
              doctor: selectedDoctorId,
              debuitAccessDate: startDate,
              finAccessDate: endDate,
              fileUrl: widget.fileUrl,
            );

            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

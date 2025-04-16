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

import '../../services/document_service.dart';

class FileListeScreen extends StatefulWidget {
  final String category;

  const FileListeScreen({super.key, required this.category});

  @override
  State<FileListeScreen> createState() => _FileListeScreenState();
}

class _FileListeScreenState extends State<FileListeScreen> {
  @override
  void initState() {
    super.initState();
    // Load files after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final medicalRecordsService =
          Provider.of<MedicalRecordsService>(context, listen: false);
      medicalRecordsService.loadFiles(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final medicalRecordsService = Provider.of<MedicalRecordsService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HealthChaine',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 30.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_rounded),
            onPressed: () {},
            color: Color(0xD25B5B5B),
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
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Color(0xFFCBE0F3),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<dynamic>>(
                  stream: medicalRecordsService.filesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No files found.'));
                    }

                    final files = snapshot.data!;
                    return ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        return FileCategoryCard(
                          title: file['fileName'] ?? 'Unnamed File',
                          uploudDate:
                              file['uplodeDate'] ?? 'no data cration File',
                          onMorePressed: () {
                            _showFileActions(context, file);
                          },
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
              builder: (context) => FilePickerScreen(category: widget.category),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}

void _showFileActions(BuildContext context, dynamic file) {
  final UserService userService = UserService();
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
                leading: Icon(Icons.visibility),
                title: Text('View File'),
                onTap: () async {
                  Navigator.pop(context);

                  final url = file['fileUrl'];
                  final fileName = file['fileName'] ?? 'downloaded_file.pdf';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SfPdfViewerPage(url: file['fileUrl']),
                    ),
                  );
                }),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Give file access'),
              onTap: () async {
                final List<Map<String, dynamic>> doctors =
                    await userService.getAllDoctors();
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
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete File'),
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
  final medicalRecordsService =
      Provider.of<MedicalRecordsService>(context, listen: false);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Delete File'),
        content: Text('Are you sure you want to delete "${file['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              medicalRecordsService.deleteFile(file['_id'], file['fileType']);
              // ScaffoldMessenger.of(context).showSnackBar(
              //  // SnackBar(content: Text('File "${file['_id']}" deleted.')),
              // );
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

class SfPdfViewerPage extends StatelessWidget {
  final String url;

  const SfPdfViewerPage({super.key, required this.url});

  bool isImageFile(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType != null && mimeType.startsWith('image/');
  }

  bool isPdfFile(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType != null && mimeType == 'application/pdf';
  }

  @override
  Widget build(BuildContext context) {
    final isImage = isImageFile(url);
    final isPdf = isPdfFile(url);

    return Scaffold(
      appBar: AppBar(title: Text("Preview")),
      body: isPdf
          ? SfPdfViewer.network(url)
          : isImage
              ? InteractiveViewer(
                  child: Center(
                    child: Image.network(
                      url,
                      errorBuilder: (context, error, stackTrace) =>
                          Text("Failed to load image"),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    "Unsupported file format.",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
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

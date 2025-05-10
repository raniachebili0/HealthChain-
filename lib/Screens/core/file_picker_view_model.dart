import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:pdfx/pdfx.dart';

class FilePickerViewModel extends ChangeNotifier {
  final MedicalRecordsService _medicalRecordsService;
  final String category;
  String? _selectedFilePath;
  bool _isLoading = false;
  String? _error;
  PdfController? pdfController;

  FilePickerViewModel({
    required MedicalRecordsService medicalRecordsService,
    required this.category,
  }) : _medicalRecordsService = medicalRecordsService;

  bool get isLoading => _isLoading;

  String? get error => _error;

  String? get selectedFilePath => _selectedFilePath;

  bool get hasSelectedFile => _selectedFilePath != null;

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        _selectedFilePath = result.files.single.path!;
        if (_selectedFilePath!.toLowerCase().endsWith('.pdf')) {
          pdfController =
              PdfController(document: PdfDocument.openFile(_selectedFilePath!));
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String?> uploadFile() async {
    if (_selectedFilePath == null || !File(_selectedFilePath!).existsSync()) {
      _error = 'No file selected or invalid file path';
      notifyListeners();
      return 'error';
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final file = File(_selectedFilePath!);
      final response = await _medicalRecordsService.uploadFile(file, category);

      _isLoading = false;
      notifyListeners();

      if (response['message'] == 'file type invalide') {
        return 'invalid_type';
      }

      await _medicalRecordsService.loadFiles(category);
      return 'success';
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return 'error';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _selectedFilePath = null;
    pdfController = null;
    _error = null;
    notifyListeners();
  }
}

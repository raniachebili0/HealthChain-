import 'package:flutter/material.dart';
import 'package:health_chain/services/document_service.dart';

class DocumentsViewModel extends ChangeNotifier {
  final MedicalRecordsService _medicalRecordsService;
  bool _isLoading = false;
  String? _error;
  Map<String, int> _fileCounts = {};

  DocumentsViewModel({
    required MedicalRecordsService medicalRecordsService,
  }) : _medicalRecordsService = medicalRecordsService {
    loadFileCounts();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get fileCounts => _fileCounts;

  Future<void> loadFileCounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final categories = [
        'allergy-intolerance',
        'diagnostic-report',
        'imaging-study',
        'medication-request',
        'observation',
        'procedure',
      ];

      for (final category in categories) {
        final files = await _medicalRecordsService.getFilesList(category);
        _fileCounts[category] = files.length;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  int getFileCount(String category) {
    return _fileCounts[category] ?? 0;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
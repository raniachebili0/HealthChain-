import 'package:flutter/material.dart';
import 'package:health_chain/services/document_service.dart';
import 'package:health_chain/services/user_service.dart';

class FileListViewModel extends ChangeNotifier {
  final MedicalRecordsService _medicalRecordsService;
  final UserService _userService;
  final String category;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  FileListViewModel({
    required MedicalRecordsService medicalRecordsService,
    required UserService userService,
    required this.category,
  })  : _medicalRecordsService = medicalRecordsService,
        _userService = userService {
    loadFiles();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Stream<List<dynamic>> get filesStream => _medicalRecordsService.filesStream;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadFiles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _medicalRecordsService.loadFiles(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteFile(String fileId, String fileType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _medicalRecordsService.deleteFile(fileId, fileType);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      return await _userService.getAllDoctors();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
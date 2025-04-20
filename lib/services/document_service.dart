import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

class MedicalRecordsService extends ChangeNotifier {
  final String baseUrl = kIsWeb
      ? 'http://localhost:3006/medical-records'
      : 'http://10.0.2.2:3006/medical-records';
  final storage = FlutterSecureStorage();

  final _filesController = StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> get filesStream => _filesController.stream;

  Future<void> loadFiles(String category) async {
    var files = await getFilesList(category);
    _filesController.add(files);
  }

  Future<String?> getAuthToken() async {
    return await storage.read(key: "auth_token");
  }

  Future<Map<String, dynamic>> uploadFile(File file, String fileType) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $authToken'
        ..fields['fileType'] = fileType
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: MediaType.parse(
                lookupMimeType(file.path) ?? 'application/octet-stream'),
          ),
        );

      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      throw Exception('Error uploading file: $e');
    }
  }

  Future<List<dynamic>> getFilesList(String fileType) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");
      var response = await http.get(
        Uri.parse('$baseUrl/getfiles?fileType=$fileType'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load files list');
      }
    } catch (e) {
      throw Exception('Error fetching files: $e');
    }
  }

  Future<List<dynamic>> getAccessFilesList() async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");
      var response = await http.get(
        Uri.parse('$baseUrl/getAccessfiles'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load files list');
      }
    } catch (e) {
      throw Exception('Error fetching files: $e');
    }
  }

  Future<String> viewFile(String fileId) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      var response = await http.get(
        Uri.parse('$baseUrl/$fileId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Directory tempDir = await getTemporaryDirectory();
        String filePath =
            '${tempDir.path}/downloaded_file.pdf'; // Adjust based on file type

        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        return filePath; // ✅ Return file path instead of void
      } else {
        throw Exception('Failed to download file');
      }
    } catch (e) {
      throw Exception('Error viewing file: $e');
    }
  }

  Future<void> deleteFile(String fileId, String category) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");
      var response = await http.delete(
        Uri.parse('$baseUrl/$fileId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadFiles(category); // Return file content or URL
      } else {
        throw Exception('Failed to delete file');
      }
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  Future<void> createAccessFile({
    required String fileName,
    String? doctor,
    String? description,
    DateTime? debuitAccessDate,
    DateTime? finAccessDate,
    String? fileUrl,
    String? fileType,
  }) async {
    final url = Uri.parse('$baseUrl/accessfile');
    String? user = await storage.read(key: "user_id");
    final body = {
      'fileName': fileName,
      'patient': user,
      'doctor': doctor,
      if (debuitAccessDate != null)
        'DebuitAccessDate': debuitAccessDate.toIso8601String(),
      if (finAccessDate != null)
        'FinAccessDate': finAccessDate.toIso8601String(),
      if (fileUrl != null) 'fileUrl': fileUrl,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('File access created successfully: ${response.body}');
      } else {
        print('Failed to create file access: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  // Method to refresh the files list for a specific category
  Future<void> refreshFilesList(String category) async {
    try {
      final files = await getFilesList(category);
      _filesController.add(files);
      print("Refreshed files list for category: $category, found ${files.length} files");
    } catch (e) {
      print("Error refreshing files list: $e");
      // Add empty list to avoid breaking the UI
      _filesController.add([]);
    }
  }
  
  // Get files from all categories
  Future<void> refreshAllCategories() async {
    try {
      for (String category in ['observation', 'procedure', 'imaging-study', 'medication-request']) {
        await refreshFilesList(category);
      }
    } catch (e) {
      print("Error refreshing all categories: $e");
    }
  }

  // Search for files by user ID
  Future<List<dynamic>> searchFilesByUserId(String userId) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");
      
      // Fix double-slash issue by ensuring URL path is properly formatted
      final url = Uri.parse('$baseUrl/search').replace(
        queryParameters: {'userId': userId}
      );
      
      print("Searching files with URL: $url");
      
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print("Search failed with status: ${response.statusCode}, body: ${response.body}");
        // Return empty list for 404 Not Found to avoid breaking UI
        if (response.statusCode == 404) {
          return [];
        }
        throw Exception('Failed to search files: ${response.body}');
      }
    } catch (e) {
      print("Error searching files: $e");
      // Return empty list to avoid breaking UI
      return [];
    }
  }
}

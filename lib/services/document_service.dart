import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:health_chain/models/SharedData.dart';

class MedicalRecordsService extends ChangeNotifier {
  final String baseUrl = 'http://10.0.2.2:3000/medical-records';
  final storage = FlutterSecureStorage();
  final SharedData _sharedData = SharedData();

  final _filesController = StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> get filesStream => _filesController.stream;

  Future<void> loadFiles(String category) async {
    var files = await getFilesList(category);
    _filesController.add(files);
  }

  Future<String?> getAuthToken() async {
    return await storage.read(key: "auth_token");
  }

  Future<Map<String, dynamic>> uploadFile(File file, String category) async {
    try {
      String? authToken = await getAuthToken();
      if (authToken == null) throw Exception("Authentication token is missing");

      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $authToken'
        ..fields['fileType'] = category
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
        final decoded = json.decode(response.body);
        if (decoded['files'] != null && decoded['files'] is List) {
          return decoded['files'];
        } else {
          return []; // Safe fallback
        }
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

  Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      // TODO: Implement actual API call
      return [];
    } catch (e) {
      debugPrint('Error getting documents: $e');
      return [];
    }
  }

  Future<bool> uploadDocument(String filePath, String category) async {
    try {
      // TODO: Implement actual file upload
      return true;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    try {
      // TODO: Implement actual document deletion
      return true;
    } catch (e) {
      debugPrint('Error deleting document: $e');
      return false;
    }
  }

  Future<Map<String, int>> getDocumentCounts() async {
    try {
      // TODO: Implement actual count retrieval
      return {
        'medical_records': 0,
        'prescriptions': 0,
        'lab_results': 0,
        'imaging': 0,
        'other': 0,
      };
    } catch (e) {
      debugPrint('Error getting document counts: $e');
      return {
        'medical_records': 0,
        'prescriptions': 0,
        'lab_results': 0,
        'imaging': 0,
        'other': 0,
      };
    }
  }
}

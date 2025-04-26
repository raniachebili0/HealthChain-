import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final String baseUrl;
  final FlutterSecureStorage storage;

  UserService({
    String? baseUrl,
    FlutterSecureStorage? storage,
  })  : baseUrl = baseUrl ?? _getDefaultBaseUrl(),
        storage = storage ?? const FlutterSecureStorage();

  static String _getDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

Future<Map<String, dynamic>> analyzeDocument(String mediaPath) async {
  try {
    final String? token = await _getAuthToken();
    final uri = Uri.parse('$baseUrl/files/analyse');
    final headers = _buildHeaders(token);
    final body = json.encode({'mediaPath': mediaPath});

    final response = await http.post(uri, headers: headers, body: body);
    final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));

    if (responseData['status'] == 'success' && responseData['data'] != null) {
      final data = responseData['data'];
      return {
        'title': data['title'] ?? 'Titre inconnu',
        'Fraude': data['Fraude'] ?? false,
        'confidenceScore': data['confidenceScore'] ?? 0,
        'observations': data['observations'] ?? 'Aucune observation.',
      };
    } else {
      throw Exception('Analyse échouée : ${responseData['status']}');
    }

  } on SocketException {
    throw Exception('Erreur de connexion au serveur');
  } on FormatException {
    throw Exception('Réponse serveur mal formatée');
  }
}


  Future<void> changeUserStatus(String userId, String newStatus) async {
    try {
      final String? token = await _getAuthToken();
      final uri = Uri.parse('$baseUrl/users/status/$userId');

      final response = await http.patch(
        uri,
        headers: _buildHeaders(token),
        body: json.encode({'status': newStatus}),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Échec du changement de statut: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final String? token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/allusers'),
        headers: _buildHeaders(token),
      );

      return List<Map<String, dynamic>>.from(_handleResponse(response));
    } catch (e) {
      throw Exception('Échec du chargement des utilisateurs: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final String? token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/getuserinfo/$userId'),
        headers: _buildHeaders(token),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Échec du chargement de l\'utilisateur: ${e.toString()}');
    }
  }

  

  Future<String?> _getAuthToken() async {
    return await storage.read(key: 'access_token');
  }

  Map<String, String> _buildHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentification requise');
    } else if (response.statusCode == 403) {
      throw Exception('Accès refusé');
    } else if (response.statusCode == 404) {
      throw Exception('Ressource non trouvée');
    } else {
      throw Exception(
        'Erreur ${response.statusCode}: ${response.body.isNotEmpty ? response.body : 'Erreur inconnue'}',
      );
    }
  }

// Add to UserService class
Future<List<Map<String, dynamic>>> findDoctors() async {
  try {
    final String? token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/doctors'),
      headers: _buildHeaders(token),
    );
    
    return List<Map<String, dynamic>>.from(_handleResponse(response));
  } catch (e) {
    throw Exception('Failed to fetch doctors: ${e.toString()}');
  }
}

Future<List<Map<String, dynamic>>> findPatients() async {
  try {
    final String? token = await _getAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/patients'),
      headers: _buildHeaders(token),
    );
    
    return List<Map<String, dynamic>>.from(_handleResponse(response));
  } catch (e) {
    throw Exception('Failed to fetch patients: ${e.toString()}');
  }
}

}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://localhost:3000";  // Remplace par l'URL de ton backend
  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String accessToken = data['accessToken'];
        final String refreshToken = data['refreshToken'];
        final String userId = data['userId'];

        // Stocker les tokens
        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'refresh_token', value: refreshToken);

        // Récupérer les informations complètes de l'utilisateur
        final userResponse = await http.get(
          Uri.parse('$baseUrl/users/$userId'), // Endpoint pour récupérer l'utilisateur
          headers: {'Authorization': 'Bearer $accessToken'},
        );

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          final String role = userData['role']; // Extraire le rôle depuis MongoDB

          // Stocker le rôle dans le stockage sécurisé
          await storage.write(key: 'user_role', value: role);

          if (role.toLowerCase() == "admin") {
            return {'success': true, 'message': 'Login successful'};
          } else {
            return {'success': false, 'message': 'Accès refusé : seul un administrateur peut se connecter.'};
          }
        } else {
          return {'success': false, 'message': 'Erreur lors de la récupération des informations utilisateur.'};
        }
      } else {
        return {'success': false, 'message': 'Identifiants incorrects'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = "AIzaSyBOnH7Cojye861ssdD6XwQNzoWXyGBDMyA";  // Remplacez par votre clé API valide
  final String _baseUrl = "https://vision.googleapis.com/v1/images:annotate";
  final String _backendUrl = "http://localhost:3000/files/process-voice";

  Future<Map<String, dynamic>> analyzeImage(String imageUrl) async {
    final requestPayload = {
      "requests": [
        {
          "image": {
            "source": {
              "imageUri": imageUrl,
            }
          },
          "features": [
            {
              "type": "LABEL_DETECTION", // Vous pouvez également changer ce type si nécessaire
              "maxResults": 10,
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception("Échec de l'appel à l'API : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors de l'appel à l'API : $e");
    }
  }
  Future<String?> processVoiceCommand(String text) async {
    try {
      print('Processing voice command: $text');
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('Voice command processed successfully: ${data['data']['command']}');
          return data['data']['command']?.toString();
        }
      }
      return null;
    } catch (e) {
      throw Exception("Voice processing failed: $e");
    }
  }
}

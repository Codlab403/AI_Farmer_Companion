import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Centralised base URL (update IP if it changes)
  static final String _baseUrl = kIsWeb
    ? 'http://192.168.8.8:8000' // For Flutter web
    : 'http://10.0.2.2:8000'; // Android emulator

  static Future<List<dynamic>> fetchMarketPrices() async {
    final url = Uri.parse('$_baseUrl/api/v1/data/market-prices');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load market prices (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your network connection.');
    }
  }

  static Future<List<dynamic>> fetchCropInfo() async {
    final url = Uri.parse('$_baseUrl/api/v1/data/crop-info');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load crop info (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your network connection.');
    }
  }

  static Future<Map<String, dynamic>> diagnosePest(String imagePath) async {
    final url = Uri.parse('$_baseUrl/api/v1/data/pest-diagnose');
    try {
      final request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to diagnose pest (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your network connection.');
    }
  }

  static Future<Map<String, dynamic>> askAssistant(String text, {String languageCode = 'en'}) async {
    final url = Uri.parse('$_baseUrl/api/v1/chat/ask');
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    print('DEBUG - Loaded JWT token: $token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final body = {
      'text_input': text,
      'language_code': languageCode,
    };
    print('DEBUG - Sending request to: $url');
    print('DEBUG - Request headers: {Content-Type: application/json, Authorization: Bearer $token}');
    print('DEBUG - Request body: $body');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      ).timeout(const Duration(seconds: 60));
      print('DEBUG - Status code: \\${response.statusCode}');
      print('DEBUG - Response body: \\${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        final detail = errorBody['detail'] ?? 'Unknown error';
        throw Exception('Failed to get AI response: $detail (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your network connection.');
    }
  }
}

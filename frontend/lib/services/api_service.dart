import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // Centralised base URL (update IP if it changes)
  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://0.0.0.0:8000'; // For Flutter web (update to your backend IP)
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Android emulator
    }
    if (Platform.isIOS) {
      return 'http://localhost:8000'; // iOS simulator
    }
    // For real devices, set your computer's LAN IP
    return 'http://0.0.0.0:8000'; // Update to your backend IP
  }

  static Future<List<dynamic>> fetchMarketPrices() async {
    final url = Uri.parse('${getBaseUrl()}/api/v1/data/market-prices');
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
    final url = Uri.parse('${getBaseUrl()}/api/v1/data/crop-info');
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
    final url = Uri.parse('${getBaseUrl()}/api/v1/data/pest-diagnose');
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

  static Future<String?> _getAccessToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    final accessToken = session?.accessToken;
    print('Access token: $accessToken');
    return accessToken;
  }

  static Future<Map<String, dynamic>> askAssistant(String text, {String languageCode = 'en'}) async {
    final url = Uri.parse('${getBaseUrl()}/api/v1/chat/ask');
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final body = {
      'text_input': text,
      'language_code': languageCode,
    };
    print('DEBUG - Sending request to: $url');
    print('DEBUG - Request headers: {Content-Type: application/json, Authorization: Bearer $accessToken}');
    print('DEBUG - Request body: $body');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
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
        throw Exception('Failed to get AI response: $detail (Status code: \\${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your network connection.');
    }
  }

  /// Fetch 24-hour weather forecast from backend.
  static Future<Map<String, dynamic>> fetchWeather({double lat = 9.145, double lon = 40.48967}) async {
    final url = Uri.parse('${getBaseUrl()}/api/v1/weather?lat=$lat&lon=$lon');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server. Please check your network connection.');
    }
  }
}

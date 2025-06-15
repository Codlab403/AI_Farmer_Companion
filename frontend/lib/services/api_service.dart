import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb; // For platform check
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  // Centralized base URL (consider using environment variables for different environments)
  // IMPORTANT: Update this to the actual IP/hostname where your backend is accessible
  // from the device/emulator running the frontend. For local development, 127.0.0.1
  // or your local network IP might work.
  static const String _baseUrl = 'http://127.0.0.1:8000'; // Changed from 0.0.0.0

  // Helper to get the base URL (can be extended for platform-specific overrides if needed)
  static String getBaseUrl() {
     // The original code had platform-specific IPs. For simplicity and to centralize,
     // we'll use a single base URL constant. In a real app, you might use
     // flutter_dotenv or similar for environment-specific configuration.
     // The 10.0.2.2 for Android emulator is a common pattern, but hardcoding
     // IPs is generally discouraged.
     if (kIsWeb) {
       return _baseUrl; // Or a web-specific URL if needed
     }
     if (Platform.isAndroid) {
       return 'http://10.0.2.2:8000'; // Keep Android emulator specific IP for convenience
     }
     // Default for other platforms (iOS simulator, desktop, real devices)
     return _baseUrl;
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

  /// Send farm profile data to the backend.
  static Future<Map<String, dynamic>> postFarmProfile(Map<String, dynamic> profileData) async {
    final url = Uri.parse('${getBaseUrl()}/api/v1/farm-profile');
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    print('DEBUG - Sending farm profile data to: $url');
    print('DEBUG - Request headers: {Content-Type: application/json, Authorization: Bearer $accessToken}');
    print('DEBUG - Request body: $profileData');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(profileData),
      ).timeout(const Duration(seconds: 30)); // Adjust timeout as needed
      print('DEBUG - Farm profile POST status code: \\${response.statusCode}');
      print('DEBUG - Farm profile POST response body: \\${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        final detail = errorBody['detail'] ?? 'Unknown error';
        throw Exception('Failed to save farm profile: $detail (Status code: \\${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or save profile: ${e.toString()}');
    }
  }

  /// Send feedback for an AI chat message to the backend.
  static Future<Map<String, dynamic>> postFeedback(String messageId, String feedbackType) async {
    final url = Uri.parse('${getBaseUrl()}/api/v1/chat/feedback');
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Authentication token not found. Please log in.');
    }
    final body = {
      'message_id': messageId,
      'feedback_type': feedbackType,
    };
    print('DEBUG - Sending feedback to: $url');
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
      ).timeout(const Duration(seconds: 10)); // Adjust timeout as needed
      print('DEBUG - Feedback POST status code: \\${response.statusCode}');
      print('DEBUG - Feedback POST response body: \\${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        final detail = errorBody['detail'] ?? 'Unknown error';
        throw Exception('Failed to submit feedback: $detail (Status code: \\${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or submit feedback: ${e.toString()}');
    }
  }

  /// Uploads an audio file for transcription to the backend.
  static Future<Map<String, dynamic>> uploadAudioForTranscription(String audioFilePath) async {
    final url = Uri.parse('${getBaseUrl()}/api/v1/voice/transcribe');
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(await http.MultipartFile.fromPath('audio_file', audioFilePath));

      print('DEBUG - Sending audio file for transcription to: $url');
      final response = await request.send().timeout(const Duration(seconds: 60)); // Adjust timeout as needed

      final responseBody = await response.stream.bytesToString();
      print('DEBUG - Transcription POST status code: ${response.statusCode}');
      print('DEBUG - Transcription POST response body: $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        final errorBody = json.decode(responseBody);
        final detail = errorBody['detail'] ?? 'Unknown error';
        throw Exception('Failed to transcribe audio: $detail (Status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server or upload audio: ${e.toString()}');
    }
  }
}

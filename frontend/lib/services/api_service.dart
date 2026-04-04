// frontend\lib\services\api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kDebugMode and kIsWeb
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // 1. the base URL
  // In Flutter, String.fromEnvironment is populated at compile-time via --dart-define
  static const String _envApiUrl = String.fromEnvironment('API_URL');

  // 2. Dynamically determine the base URL
  static String get baseUrl {
    // Priority 1: Check environment variable (populated via --dart-define)
    if (_envApiUrl.isNotEmpty) {
      print('[DEBUG URL] Environment API_URL detected: "$_envApiUrl"');
      return _envApiUrl;
    }

    // Priority 2: Use local fallback for debug mode (Development)
    if (kDebugMode) {
      const String localUrl = 'http://10.0.2.2:5000';
      print('[DEBUG URL] Using local development fallback: "$localUrl"');
      return localUrl;
    }

    // Priority 3: Use production fallback
    const String productionUrl = 'https://mentor-mantee.onrender.com';
    print('[DEBUG URL] Using production fallback: "$productionUrl"');
    return productionUrl;
  }

  final _storage = const FlutterSecureStorage();

  // ... (rest of your methods: _getHeaders, get, post, etc. stay exactly the same)

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/api$endpoint');
    final headers = await _getHeaders();
    print('GET Request: $url');

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 60));
      return _handleResponse(response);
    } catch (e) {
      print('API Error (GET $endpoint): $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api$endpoint');
    final headers = await _getHeaders();
    print('POST Request: $url');
    print('Payload: $data');

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 60));
      return _handleResponse(response);
    } catch (e) {
      print('API Error (POST $endpoint): $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api$endpoint');
    final headers = await _getHeaders();
    print('PUT Request: $url');

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('API Error (PUT $endpoint): $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api$endpoint');
    final headers = await _getHeaders();
    print('PATCH Request: $url');

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      print('API Error (PATCH $endpoint): $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/api$endpoint');
    final headers = await _getHeaders();
    print('DELETE Request: $url');

    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      print('API Error (DELETE $endpoint): $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      // [DEBUG] Log the full response body to see the exact error message from the server
      print('[DEBUG URL] Request failed with status: ${response.statusCode}');
      print('[DEBUG URL] Response body: ${response.body}');

      String errorMessage =
          'Request failed with status: ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map) {
          if (body.containsKey('message')) {
            errorMessage = body['message'];
          }
          if (body.containsKey('error')) {
            errorMessage += ': ${body['error']}';
          }
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}

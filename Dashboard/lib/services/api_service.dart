import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:4000'; // Change to your backend URL
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
    debugPrint('🔑 [API] Auth token set');
  }

  static void clearAuthToken() {
    _authToken = null;
    debugPrint('🔑 [API] Auth token cleared');
  }

  static Map<String, String> _getHeaders({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      debugPrint('🔵 [API] GET $baseUrl$endpoint');
      final stopwatch = Stopwatch()..start();

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      stopwatch.stop();
      debugPrint(
        '✅ [API] GET $baseUrl$endpoint - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [API] Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('🔵 [API] POST $baseUrl$endpoint');
      final stopwatch = Stopwatch()..start();

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(extra: headers),
        body: jsonEncode(body),
      );

      stopwatch.stop();
      debugPrint(
        '✅ [API] POST $baseUrl$endpoint - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [API] Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      debugPrint('🔵 [API] DELETE $baseUrl$endpoint');
      final stopwatch = Stopwatch()..start();

      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      stopwatch.stop();
      debugPrint(
        '✅ [API] DELETE $baseUrl$endpoint - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.statusCode == 204
            ? {}
            : jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ [API] Error: $e');
      rethrow;
    }
  }
}

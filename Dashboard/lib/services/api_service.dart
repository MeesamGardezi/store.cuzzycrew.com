import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );
  static String? _authToken;
  static String? _refreshToken;
  static http.Client? _client;

  static void setAuthToken(String token) {
    _authToken = token;
    debugPrint('🔑 [API] Auth token set');
  }

  static void setAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) {
    _authToken = accessToken;
    _refreshToken = refreshToken;
    debugPrint('🔑 [API] Auth tokens updated');
  }

  static void clearAuthToken() {
    _authToken = null;
    _refreshToken = null;
    debugPrint('🔑 [API] Auth token cleared');
  }

  static void setClient(http.Client? client) {
    _client = client;
  }

  static Map<String, String> _getHeaders({
    Map<String, String>? extra,
    bool includeContentType = true,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
    if (!includeContentType) {
      headers.remove('Content-Type');
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  static Future<bool> _tryRefreshAccessToken() async {
    final refreshToken = _refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final client = _client ?? http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        clearAuthToken();
        return false;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      final newAccessToken = data?['accessToken'] as String?;
      if (newAccessToken == null || newAccessToken.isEmpty) {
        clearAuthToken();
        return false;
      }

      _authToken = newAccessToken;
      debugPrint('🔁 [API] Access token refreshed');
      return true;
    } catch (_) {
      clearAuthToken();
      return false;
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      debugPrint('🔵 [API] GET $baseUrl$endpoint');
      final stopwatch = Stopwatch()..start();

      final client = _client ?? http.Client();
      var response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 401 && endpoint != '/api/auth/refresh') {
        final refreshed = await _tryRefreshAccessToken();
        if (refreshed) {
          response = await client.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
          );
        }
      }

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

      final client = _client ?? http.Client();
      var response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(extra: headers),
        body: jsonEncode(body),
      );

      if (response.statusCode == 401 && endpoint != '/api/auth/refresh') {
        final refreshed = await _tryRefreshAccessToken();
        if (refreshed) {
          response = await client.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(extra: headers),
            body: jsonEncode(body),
          );
        }
      }

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

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    List<http.MultipartFile> files = const [],
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('🔵 [API] POST $baseUrl$endpoint (multipart)');
      final stopwatch = Stopwatch()..start();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );
      request.headers.addAll(
        _getHeaders(extra: headers, includeContentType: false),
      );
      request.fields.addAll(fields);
      request.files.addAll(files);

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401 && endpoint != '/api/auth/refresh') {
        final refreshed = await _tryRefreshAccessToken();
        if (refreshed) {
          request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl$endpoint'),
          );
          request.headers.addAll(
            _getHeaders(extra: headers, includeContentType: false),
          );
          request.fields.addAll(fields);
          request.files.addAll(files);
          streamed = await request.send();
          response = await http.Response.fromStream(streamed);
        }
      }

      stopwatch.stop();
      debugPrint(
        '✅ [API] POST $baseUrl$endpoint (multipart) - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception('Request failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [API] Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      debugPrint('🔵 [API] PATCH $baseUrl$endpoint');
      final stopwatch = Stopwatch()..start();

      final client = _client ?? http.Client();
      var response = await client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(extra: headers),
        body: jsonEncode(body),
      );

      if (response.statusCode == 401 && endpoint != '/api/auth/refresh') {
        final refreshed = await _tryRefreshAccessToken();
        if (refreshed) {
          response = await client.patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(extra: headers),
            body: jsonEncode(body),
          );
        }
      }

      stopwatch.stop();
      debugPrint(
        '✅ [API] PATCH $baseUrl$endpoint - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      throw Exception('Request failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [API] Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      debugPrint('🔵 [API] DELETE $baseUrl$endpoint');
      final stopwatch = Stopwatch()..start();

      final client = _client ?? http.Client();
      var response = await client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 401 && endpoint != '/api/auth/refresh') {
        final refreshed = await _tryRefreshAccessToken();
        if (refreshed) {
          response = await client.delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(),
          );
        }
      }

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

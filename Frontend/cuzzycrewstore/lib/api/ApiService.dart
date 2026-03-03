import 'dart:convert';

import 'package:cuzzycrewstore/api/ApiConstants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({this.baseUrl = ApiConstants.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Map<String, String> _headers({Map<String, String>? extra}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> createOrder({
    required String shippingAddressId,
    required String idempotencyKey,
  }) async {
    final uri = _uri(ApiConstants.createOrder);
    debugPrint('🔵 [API] POST ${uri.toString()}');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.post(
        uri,
        headers: _headers(extra: {'Idempotency-Key': idempotencyKey}),
        body: jsonEncode({'shippingAddressId': shippingAddressId}),
      );
      stopwatch.stop();

      debugPrint(
        '✅ [API] POST ${uri.toString()} - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      return _parseJsonResponse(response);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ [API] POST ${uri.toString()} - Error: $e - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required String orderId,
  }) async {
    final uri = _uri(ApiConstants.paymentIntent);
    debugPrint('🔵 [API] POST ${uri.toString()}');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'orderId': orderId}),
      );
      stopwatch.stop();

      debugPrint(
        '✅ [API] POST ${uri.toString()} - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      return _parseJsonResponse(response);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ [API] POST ${uri.toString()} - Error: $e - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus({
    required String orderId,
  }) async {
    final uri = _uri(ApiConstants.paymentStatus(orderId));
    debugPrint('🔵 [API] GET ${uri.toString()}');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.get(uri, headers: _headers());
      stopwatch.stop();

      debugPrint(
        '✅ [API] GET ${uri.toString()} - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      return _parseJsonResponse(response);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ [API] GET ${uri.toString()} - Error: $e - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    final uri = _uri(ApiConstants.CategoriesFetch);
    debugPrint('🔵 [API] GET ${uri.toString()}');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.get(uri, headers: _headers());
      stopwatch.stop();

      debugPrint(
        '✅ [API] GET ${uri.toString()} - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      return _parseJsonResponse(response);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ [API] GET ${uri.toString()} - Error: $e - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProducts({
    int limit = 50,
    String? cursor,
    String? category,
  }) async {
    final uri = Uri.parse('$baseUrl${ApiConstants.AllProductFetch}');
    debugPrint('🔵 [API] GET ${uri.toString()}');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.get(uri, headers: _headers());
      stopwatch.stop();

      debugPrint(
        '✅ [API] GET ${uri.toString()} - Status: ${response.statusCode} - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      return _parseJsonResponse(response);
    } catch (e) {
      stopwatch.stop();
      debugPrint(
        '❌ [API] GET ${uri.toString()} - Error: $e - Time: ${stopwatch.elapsedMilliseconds}ms',
      );
      rethrow;
    }
  }

  Map<String, dynamic> _parseJsonResponse(http.Response response) {
    final jsonBody =
        response.body.trim().isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }

    final error = jsonBody['error'] as Map<String, dynamic>?;
    final message =
        (error?['message'] ?? 'Request failed (${response.statusCode})')
            .toString();
    throw Exception(message);
  }
}

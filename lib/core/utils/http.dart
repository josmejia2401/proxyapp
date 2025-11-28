import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'http_interceptor.dart';
import 'dart:convert';

class HttpService {
  static InterceptedClient? _client;
  static late String _baseUrl;

  static void init({
    required String baseUrl,
    void Function()? onUnauthorized,
  }) {
    if (_client != null) return; // Ya inicializado

    _baseUrl = baseUrl;
    _client = InterceptedClient.build(
      interceptors: [AuthInterceptor(onUnauthorized: onUnauthorized)],
      requestTimeout: const Duration(seconds: 15),
    );
  }

  static InterceptedClient get client {
    if (_client == null) {
      throw Exception('HttpService no fue inicializado. Llama a init() primero.');
    }
    return _client!;
  }

  static Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse(_baseUrl);
    return uri.replace(
      path: '${uri.path}$path',
      queryParameters: queryParams,
    );
  }

  // Métodos HTTP con headers y body en JSON
  static Future<http.Response> get(
      String path, {
        Map<String, dynamic>? queryParams,
        Map<String, String>? headers,
      }) {
    return client.get(
      _buildUri(path, queryParams),
      headers: headers,
    );
  }

  static Future<http.Response> post(
      String path, {
        Object? body,
        Map<String, String>? headers,
      }) {
    return client.post(
      _buildUri(path),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> put(
      String path, {
        Object? body,
        Map<String, String>? headers,
      }) {
    return client.put(
      _buildUri(path),
      headers: {
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: body != null ? jsonEncode(body) : null,
    );
  }

  static Future<http.Response> delete(
      String path, {
        Map<String, String>? headers,
      }) {
    return client.delete(
      _buildUri(path),
      headers: headers,
    );
  }

  static void dispose() {
    _client?.close();
    _client = null;
  }
}

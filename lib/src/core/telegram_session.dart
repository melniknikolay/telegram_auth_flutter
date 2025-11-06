import 'package:dio/dio.dart';

/// Manages HTTP session with cookie handling for Telegram OAuth
class TelegramSession {
  /// Creates a [TelegramSession] with the given [dio] instance
  TelegramSession(Dio? dio) : _dio = dio ?? Dio();

  final Dio _dio;
  final Map<String, String?> _cookies = {};

  /// Makes an HTTP request with cookie management
  Future<String> request(
    String method,
    String url, {
    Map<String, String>? headers,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? data,
  }) async {
    final response = await _dio.request<String>(
      url,
      queryParameters: queryParameters,
      data: data,
      options: Options(
        method: method,
        headers: <String, dynamic>{
          if (headers != null) ...headers,
          'cookie': _cookiesAsString(),
        },
      ),
    );

    final cookiesInfo = response.headers['set-cookie'];
    if (cookiesInfo != null) {
      _addCookiesFromCookiesInfo(cookiesInfo);
    }

    return response.data ?? '';
  }

  /// Makes a GET request
  Future<String> get(
    String url, {
    Map<String, String>? headers,
    Map<String, Object?>? queryParameters,
  }) =>
      request(
        'GET',
        url,
        headers: headers,
        queryParameters: queryParameters,
      );

  /// Makes a POST request
  Future<String> post(
    String url, {
    Map<String, String>? headers,
    Map<String, Object?>? queryParameters,
    Map<String, Object?>? data,
  }) =>
      request(
        'POST',
        url,
        headers: headers,
        queryParameters: queryParameters,
        data: data,
      );

  /// Extracts and stores cookies from response headers
  void _addCookiesFromCookiesInfo(List<String> cookiesInfo) {
    for (final group in cookiesInfo) {
      final cookies = group.split(';');
      for (final cookie in cookies) {
        final parts = cookie.split('=');
        final name = parts[0].trim();
        final value = parts.length == 1 ? null : parts[1];

        if (name != 'HttpOnly') {
          _cookies[name] = value;
        }
      }
    }
  }

  /// Converts stored cookies to header string
  String _cookiesAsString() => _cookies.entries.map((e) => '${e.key}${e.value == null ? '' : '=${e.value}'}').join('; ');

  /// Clears all stored cookies
  void clearCookies() {
    _cookies.clear();
  }

  /// Gets a copy of current cookies
  Map<String, String?> get cookies => Map.unmodifiable(_cookies);
}

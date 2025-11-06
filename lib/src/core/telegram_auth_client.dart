import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/telegram_auth_result.dart';
import '../models/telegram_exception.dart';
import '../models/telegram_user.dart';
import 'telegram_config.dart';
import 'telegram_session.dart';

/// Main client for Telegram OAuth authentication
class TelegramAuthClient {
  /// Creates a [TelegramAuthClient] with the given [config]
  ///
  /// Optionally provide a custom [dio] instance for HTTP requests
  TelegramAuthClient({
    required TelegramConfig config,
    Dio? dio,
  })  : _config = config,
        _session = TelegramSession(dio) {
    _config.validate();
  }

  static const String _telegramEndPointApi = 'https://oauth.telegram.org/auth';

  final TelegramConfig _config;
  final TelegramSession _session;

  /// Initiates login with the given [phoneNumber]
  ///
  /// Phone number must be in international format: +1234567890
  ///
  /// Returns a [TelegramAuthResult] with the authenticated user or error
  ///
  /// Example:
  /// ```dart
  /// final result = await client.login('+1234567890');
  /// if (result.isSuccess) {
  ///   print('Welcome ${result.user!.fullName}');
  /// } else {
  ///   print('Error: ${result.error}');
  /// }
  /// ```
  Future<TelegramAuthResult> login(String phoneNumber) async {
    try {
      // Validate phone number
      _validatePhoneNumber(phoneNumber);

      // Step 1: Request authentication
      await _requestAuth(phoneNumber);

      // Step 2: Poll for login completion
      final loginCompleted = await _pollLoginStatus();

      if (!loginCompleted) {
        return const TelegramAuthResult.failure(
          'Authentication timeout - user did not confirm login',
        );
      }

      // Step 3: Get user information
      final user = await getUserInfo();

      return TelegramAuthResult.success(user);
    } on TelegramException catch (e) {
      _config.onError?.call(e, e.stackTrace);
      return TelegramAuthResult.failure(e.message);
    } catch (e, stackTrace) {
      _config.onError?.call(e, stackTrace);
      return TelegramAuthResult.failure(e.toString());
    }
  }

  /// Requests authentication for the given [phoneNumber]
  Future<void> _requestAuth(String phoneNumber) async {
    final response = await _session.post(
      '$_telegramEndPointApi/request',
      queryParameters: _config.defaultQueryParameters,
      headers: TelegramConfig.defaultHeaders,
      data: <String, dynamic>{
        'phone': phoneNumber,
      },
    );

    if (response == 'true') return;

    throw TelegramException('Failed to request authentication: $response');
  }

  /// Polls the login status until completion or timeout
  Future<bool> _pollLoginStatus() async {
    final totalAttempts = _config.timeout.inSeconds;
    var remainingAttempts = totalAttempts;

    while (remainingAttempts > 0) {
      _config.onProgress?.call(remainingAttempts);

      final isLoggedIn = await _checkLoginStatus();
      if (isLoggedIn) {
        return true;
      }

      await Future<void>.delayed(_config.pollingInterval);
      remainingAttempts--;
    }

    return false;
  }

  /// Checks if the user has completed login
  Future<bool> _checkLoginStatus() async {
    final response = await _session.post(
      '$_telegramEndPointApi/login',
      queryParameters: _config.defaultQueryParameters,
      headers: TelegramConfig.defaultHeaders,
    );

    if (response == 'true') return true;
    if (response == 'false') return false;

    throw TelegramException('Unexpected login check response: $response');
  }

  /// Retrieves user information after successful login
  Future<TelegramUser> getUserInfo() async {
    final response = await _session.get(
      _telegramEndPointApi,
      queryParameters: _config.defaultQueryParameters,
      headers: TelegramConfig.defaultHeaders,
    );

    // Try to find user info in response
    var userInfo = _parseUserInfo(response);

    if (userInfo != null) {
      return TelegramUser.fromJson(userInfo);
    }

    // If not found, try confirm flow
    final confirmUrl = _extractUrl(response, r"var confirm_url ?= ?'([^']*)'");
    final logoutUrl = _extractUrl(response, r"location\.href ?= ?'([^']*)'");

    if (confirmUrl == null || logoutUrl == null) {
      throw const TelegramException('Failed to parse user info from response');
    }

    userInfo = await _confirmAndGetUserInfo(confirmUrl);
    await _logout(logoutUrl);

    if (userInfo == null) {
      throw const TelegramException('Failed to get user info after confirmation');
    }

    return TelegramUser.fromJson(userInfo);
  }

  /// Parses user information from response HTML
  Map<String, dynamic>? _parseUserInfo(String response) {
    try {
      final regex = RegExp(r'result: ?(\{.*?\})');
      final match = regex.firstMatch(response);
      final json = match?[1];

      if (json == null) return null;

      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Extracts URL from response using regex pattern
  String? _extractUrl(String response, String pattern) {
    final regex = RegExp(pattern);
    final match = regex.firstMatch(response);
    return match?[1];
  }

  /// Confirms authentication and retrieves user info
  Future<Map<String, dynamic>?> _confirmAndGetUserInfo(String confirmUrl) async {
    final response = await _session.get(
      '$_telegramEndPointApi$confirmUrl',
      queryParameters: _config.defaultQueryParameters,
      headers: TelegramConfig.defaultHeaders,
    );

    return _parseUserInfo(response);
  }

  /// Logs out from Telegram OAuth session
  Future<void> _logout(String logoutUrl) => _session.get(
        '$_telegramEndPointApi$logoutUrl',
        queryParameters: _config.defaultQueryParameters,
        headers: TelegramConfig.defaultHeaders,
      );

  /// Validates phone number format
  void _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      throw const TelegramException('Phone number cannot be empty');
    }

    if (!phoneNumber.startsWith('+')) {
      throw const TelegramException(
        'Phone number must be in international format: +1234567890',
      );
    }

    // Remove + and check if remaining is numeric
    final digitsOnly = phoneNumber.substring(1);
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      throw const TelegramException(
        'Phone number must contain only digits after +',
      );
    }

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      throw const TelegramException(
        'Phone number must be between 10 and 15 digits',
      );
    }
  }

  /// Clears the session cookies
  void clearSession() {
    _session.clearCookies();
  }

  /// Gets the current configuration
  TelegramConfig get config => _config;
}

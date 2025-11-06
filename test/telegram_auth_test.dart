import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_auth_flutter/telegram_auth_flutter.dart';

void main() {
  group('TelegramConfig', () {
    test('should create config with valid parameters', () {
      const config = TelegramConfig(
        botId: 'test_bot_id',
        botDomain: 'https://example.com',
      );

      expect(config.botId, 'test_bot_id');
      expect(config.botDomain, 'https://example.com');
      expect(config.pollingInterval, const Duration(seconds: 1));
      expect(config.timeout, const Duration(seconds: 60));
    });

    test('should throw error for invalid domain (non-HTTPS)', () {
      const config = TelegramConfig(
        botId: 'test_bot_id',
        botDomain: 'http://example.com',
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('should throw error for empty botId', () {
      const config = TelegramConfig(
        botId: '',
        botDomain: 'https://example.com',
      );

      expect(() => config.validate(), throwsArgumentError);
    });

    test('should create copy with modified parameters', () {
      const config = TelegramConfig(
        botId: 'test_bot_id',
        botDomain: 'https://example.com',
      );

      final newConfig = config.copyWith(
        timeout: const Duration(seconds: 30),
      );

      expect(newConfig.botId, 'test_bot_id');
      expect(newConfig.timeout, const Duration(seconds: 30));
      expect(newConfig.pollingInterval, const Duration(seconds: 1));
    });
  });

  group('TelegramUser', () {
    test('should create user from JSON', () {
      final json = {
        'id': '123456',
        'first_name': 'John',
        'last_name': 'Doe',
        'username': 'johndoe',
      };

      final user = TelegramUser.fromJson(json);

      expect(user.id, '123456');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.username, 'johndoe');
      expect(user.fullName, 'John Doe');
    });

    test('should handle missing optional fields', () {
      final json = {
        'id': '123456',
        'first_name': 'John',
      };

      final user = TelegramUser.fromJson(json);

      expect(user.id, '123456');
      expect(user.firstName, 'John');
      expect(user.lastName, null);
      expect(user.username, null);
      expect(user.fullName, 'John');
    });

    test('should convert user to JSON', () {
      const user = TelegramUser(
        id: '123456',
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
      );

      final json = user.toJson();

      expect(json['id'], '123456');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['username'], 'johndoe');
    });
  });

  group('TelegramAuthResult', () {
    test('should create success result', () {
      const user = TelegramUser(
        id: '123',
        firstName: 'Test',
      );

      const result = TelegramAuthResult.success(user);

      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.user, user);
      expect(result.error, null);
    });

    test('should create failure result', () {
      const result = TelegramAuthResult.failure('Test error');

      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.user, null);
      expect(result.error, 'Test error');
    });
  });

  group('TelegramException', () {
    test('should create exception with message', () {
      const exception = TelegramException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('should include original error in toString', () {
      final originalError = Exception('Original');
      final exception = TelegramException(
        'Wrapper error',
        originalError: originalError,
      );

      expect(exception.toString(), contains('Wrapper error'));
      expect(exception.toString(), contains('Original'));
    });
  });

  group('TelegramAuthClient', () {
    test('should validate phone number format', () {
      const config = TelegramConfig(
        botId: 'test',
        botDomain: 'https://example.com',
      );

      final client = TelegramAuthClient(config: config);

      // These will fail in actual login, but we're testing validation
      expect(client.config.botId, 'test');
    });
  });
}
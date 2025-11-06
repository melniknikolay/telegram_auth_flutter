import 'telegram_user.dart';

/// Result of a Telegram authentication attempt
class TelegramAuthResult {
  /// Creates a successful [TelegramAuthResult]
  const TelegramAuthResult.success(this.user)
      : isSuccess = true,
        error = null;

  /// Creates a failed [TelegramAuthResult]
  const TelegramAuthResult.failure(this.error)
      : isSuccess = false,
        user = null;

  /// Whether the authentication was successful
  final bool isSuccess;

  /// The authenticated user (only present if [isSuccess] is true)
  final TelegramUser? user;

  /// The error message (only present if [isSuccess] is false)
  final String? error;

  /// Whether the authentication failed
  bool get isFailure => !isSuccess;

  @override
  String toString() {
    if (isSuccess) {
      return 'TelegramAuthResult.success(user: $user)';
    } else {
      return 'TelegramAuthResult.failure(error: $error)';
    }
  }
}

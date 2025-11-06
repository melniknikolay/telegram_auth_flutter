/// Exception thrown when Telegram authentication fails
class TelegramException implements Exception {
  /// Creates a [TelegramException] with the given [message]
  const TelegramException(
    this.message, {
    this.stackTrace,
    this.originalError,
  });

  /// The error message
  final String message;

  /// Optional stack trace
  final StackTrace? stackTrace;

  /// Original error that caused this exception
  final Object? originalError;

  @override
  String toString() {
    final buffer = StringBuffer('TelegramException: $message');
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

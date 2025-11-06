/// Configuration for Telegram authentication
class TelegramConfig {
  /// Creates a [TelegramConfig] with the required parameters
  const TelegramConfig({
    required this.botId,
    required this.botDomain,
    this.pollingInterval = const Duration(seconds: 1),
    this.timeout = const Duration(seconds: 60),
    this.onProgress,
    this.onError,
  });

  /// Telegram bot ID obtained from @BotFather
  final String botId;

  /// Bot domain (must be HTTPS and match BotFather settings)
  /// Example: 'https://yourdomain.com'
  final String botDomain;

  /// Interval for checking login status
  /// Default is 1 second
  final Duration pollingInterval;

  /// Maximum time to wait for user to complete authentication
  /// Default is 60 seconds
  final Duration timeout;

  /// Optional callback for progress updates
  /// Provides remaining seconds until timeout
  final void Function(int remainingSeconds)? onProgress;

  /// Optional callback for error handling
  final void Function(Object error, StackTrace? stackTrace)? onError;

  /// Default query parameters for Telegram OAuth API
  Map<String, Object?> get defaultQueryParameters => {
        'bot_id': botId,
        'origin': botDomain,
        'embed': 1,
      };

  /// Default headers for Telegram OAuth API
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'origin': 'https://oauth.telegram.org',
  };

  /// Validates the configuration
  void validate() {
    if (botId.isEmpty) {
      throw ArgumentError('botId cannot be empty');
    }

    if (botDomain.isEmpty) {
      throw ArgumentError('botDomain cannot be empty');
    }

    if (!botDomain.startsWith('https://')) {
      throw ArgumentError('botDomain must use HTTPS');
    }

    if (pollingInterval.inMilliseconds < 100) {
      throw ArgumentError('pollingInterval must be at least 100ms');
    }

    if (timeout.inSeconds < 1) {
      throw ArgumentError('timeout must be at least 1 second');
    }
  }

  /// Creates a copy of this config with the given parameters replaced
  TelegramConfig copyWith({
    String? botId,
    String? botDomain,
    Duration? pollingInterval,
    Duration? timeout,
    void Function(int remainingSeconds)? onProgress,
    void Function(Object error, StackTrace? stackTrace)? onError,
  }) {
    return TelegramConfig(
      botId: botId ?? this.botId,
      botDomain: botDomain ?? this.botDomain,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      timeout: timeout ?? this.timeout,
      onProgress: onProgress ?? this.onProgress,
      onError: onError ?? this.onError,
    );
  }
}

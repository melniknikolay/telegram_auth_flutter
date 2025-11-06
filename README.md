# Telegram Auth Flutter

A lightweight and fast Telegram OAuth authentication package for Flutter with 1-second polling interval and clean API.

## Features

- **⚡ Fast Polling**: 1-second interval for more responsive UX
- **🎯 Lightweight**: Only Dio dependency, no UI bloat
- **🔧 Flexible Configuration**: Customizable timeouts, intervals, and callbacks
- **🛡️ Type-Safe**: Complete models for all data structures
- **📦 Zero UI Dependencies**: Pure logic, bring your own UI
- **🔐 Session Management**: Automatic cookie handling
- **✅ Validation**: Built-in phone number and config validation

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  telegram_auth_flutter: ^0.1.0
```

## Prerequisites

1. Create a Telegram bot via [@BotFather](https://t.me/BotFather)
2. Get your bot ID
3. Set up your domain in BotFather (must be HTTPS)

## Usage

### Basic Example

```dart
import 'package:telegram_auth_flutter/telegram_auth_flutter.dart';

// Create configuration
final config = TelegramConfig(
  botId: 'your_bot_id',
  botDomain: 'https://yourdomain.com',
);

// Create client
final client = TelegramAuthClient(config: config);

// Login with phone number
final result = await client.login('+1234567890');

if (result.isSuccess) {
  final user = result.user!;
  print('Welcome ${user.fullName}!');
  print('User ID: ${user.id}');
  print('Username: ${user.username}');
} else {
  print('Login failed: ${result.error}');
}
```

### Advanced Configuration

```dart
final config = TelegramConfig(
  botId: 'your_bot_id',
  botDomain: 'https://yourdomain.com',

  // Custom polling interval (default: 1 second)
  pollingInterval: Duration(milliseconds: 500),

  // Custom timeout (default: 60 seconds)
  timeout: Duration(seconds: 90),

  // Progress callback
  onProgress: (remainingSeconds) {
    print('Please confirm in Telegram: $remainingSeconds seconds remaining');
  },

  // Error callback
  onError: (error, stackTrace) {
    print('Error occurred: $error');
    // Send to your logging service
  },
);
```

### With Custom Dio Instance

```dart
final customDio = Dio(
  BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ),
);

final client = TelegramAuthClient(
  config: config,
  dio: customDio,
);
```

### Complete Flutter Example

```dart
class TelegramLoginScreen extends StatefulWidget {
  @override
  _TelegramLoginScreenState createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends State<TelegramLoginScreen> {
  final _phoneController = TextEditingController();
  int _remainingSeconds = 0;
  bool _isLoading = false;

  late final TelegramAuthClient _authClient;

  @override
  void initState() {
    super.initState();

    final config = TelegramConfig(
      botId: 'YOUR_BOT_ID',
      botDomain: 'https://yourdomain.com',
      onProgress: (remaining) {
        setState(() => _remainingSeconds = remaining);
      },
      onError: (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );

    _authClient = TelegramAuthClient(config: config);
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authClient.login(_phoneController.text);

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // Navigate to home screen or save user data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: result.user!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Unknown error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Telegram Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24),

            if (_isLoading)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Please confirm in Telegram\n$_remainingSeconds seconds remaining',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _handleLogin,
                child: Text('Login with Telegram'),
              ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### TelegramConfig

Configuration class for authentication parameters.

```dart
TelegramConfig({
  required String botId,           // Bot ID from @BotFather
  required String botDomain,       // Your HTTPS domain
  Duration pollingInterval,        // Default: 1 second
  Duration timeout,                // Default: 60 seconds
  Function(int)? onProgress,       // Progress callback
  Function(Object, StackTrace?)? onError,  // Error callback
})
```

### TelegramAuthClient

Main client for authentication.

```dart
TelegramAuthClient({
  required TelegramConfig config,
  Dio? dio,  // Optional custom Dio instance
})
```

**Methods:**
- `Future<TelegramAuthResult> login(String phoneNumber)` - Initiate login
- `void clearSession()` - Clear stored cookies

### TelegramAuthResult

Result of authentication attempt.

**Properties:**
- `bool isSuccess` - Whether authentication succeeded
- `bool isFailure` - Whether authentication failed
- `TelegramUser? user` - User data (if successful)
- `String? error` - Error message (if failed)

### TelegramUser

User information from Telegram.

**Properties:**
- `String id` - Telegram user ID
- `String firstName` - First name
- `String? lastName` - Last name (optional)
- `String? username` - Username (optional)
- `String? photoUrl` - Profile photo URL (optional)
- `DateTime? authDate` - Authentication timestamp
- `String fullName` - Computed full name
- `Map<String, dynamic>? rawData` - Original response data

**Methods:**
- `Map<String, dynamic> toJson()` - Convert to JSON
- `factory TelegramUser.fromJson(Map<String, dynamic>)` - Create from JSON

### TelegramException

Exception thrown during authentication.

```dart
const TelegramException(
  String message,
  {StackTrace? stackTrace, Object? originalError}
)
```

## Phone Number Format

Phone numbers must be in international format:
- ✅ `+1234567890`
- ✅ `+79991234567`
- ❌ `1234567890` (missing +)
- ❌ `+1-234-567-890` (no dashes)

## Error Handling

The package provides multiple ways to handle errors:

```dart
// 1. Via result object
final result = await client.login(phoneNumber);
if (result.isFailure) {
  print(result.error);
}

// 2. Via onError callback
final config = TelegramConfig(
  // ...
  onError: (error, stackTrace) {
    // Log to your service
    logger.error(error, stackTrace);
  },
);

// 3. Try-catch for exceptions
try {
  final result = await client.login(phoneNumber);
} on TelegramException catch (e) {
  print('Telegram error: ${e.message}');
} catch (e) {
  print('Unknown error: $e');
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Author

Created by Nikolay Melnik

## Support

For bugs and feature requests, please create an issue on GitHub.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
# Telegram Auth Flutter - Example App

This example demonstrates how to use the `telegram_auth_flutter` package to implement Telegram OAuth authentication in your Flutter application.

## Prerequisites

Before running this example, you need to:

1. Create a Telegram bot via [@BotFather](https://t.me/BotFather)
2. Set up a domain for authentication
3. Configure your bot credentials

## Setup

1. Open `lib/main.dart`
2. Update the `AppConstants` class with your bot credentials:

```dart
class AppConstants {
  static const String botId = 'YOUR_BOT_ID';
  static const String botDomain = 'https://yourdomain.com';
}
```

## Running the Example

```bash
# Get dependencies
flutter pub get

# Run on your preferred device
flutter run

# Or for web
flutter run -d chrome

# Or for a specific device
flutter devices
flutter run -d <device_id>
```

## Features Demonstrated

This example shows:

- Phone number input with validation
- Login request to Telegram
- Real-time polling for authentication status
- Progress indicators with remaining time
- User profile display after successful login
- Error handling and user feedback
- Proper widget lifecycle management

## Project Structure

```
example/
├── lib/
│   └── main.dart          # Main example application
├── pubspec.yaml           # Dependencies
└── README.md             # This file
```

## How It Works

1. User enters their phone number
2. App sends authentication request to Telegram
3. User receives login request in their Telegram app
4. User confirms in Telegram
5. App polls for authentication result
6. On success, displays user profile

## Troubleshooting

**Issue**: "Please enter a phone number" error
- Make sure phone number is in international format (e.g., +1234567890)

**Issue**: Timeout error
- Check your bot credentials are correct
- Ensure your domain is properly configured
- Verify network connectivity

**Issue**: Dependencies error
- Run `flutter pub get` in the example directory
- Make sure parent package dependencies are installed

## Learn More

- [Package Documentation](../README.md)
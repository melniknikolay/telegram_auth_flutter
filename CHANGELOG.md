# Changelog

All notable changes to this project will be documented in this file.


## [0.1.0] - 2025-11-06

### Added
- Initial release of telegram_auth_flutter
- Core authentication client with Telegram OAuth support
- Fast 1-second polling interval for responsive UX
- Session management with automatic cookie handling
- Comprehensive configuration options:
  - Customizable polling intervals
  - Configurable timeouts
  - Progress callbacks
  - Error callbacks
- Type-safe models:
  - `TelegramUser` - User information
  - `TelegramAuthResult` - Authentication result
  - `TelegramException` - Custom exceptions
- Built-in validation:
  - Phone number format validation
  - Configuration validation
- Clean API without UI dependencies
- Support for custom Dio instances
- Comprehensive documentation and examples
- Complete example Flutter app demonstrating usage

### Features
- **Fast Polling**: 1-second interval 
- **Lightweight**: Only Dio as dependency
- **Flexible**: Highly configurable with callbacks
- **Clean API**: No UI bloat, pure logic

### Technical Details
- Minimum SDK: Dart 3.0.0
- Minimum Flutter: 3.0.0
- Dependencies: dio ^5.8.0
- Platform Support: iOS, Android, Web, Desktop

## [Unreleased]

### Planned
- Additional language support for error messages
- Rate limiting handling
- Retry mechanism with exponential backoff
import 'package:flutter/material.dart';
import 'package:telegram_auth_flutter/telegram_auth_flutter.dart';

void main() {
  runApp(const MyApp());
}

/// App-wide constants
class AppConstants {
  static const double defaultPadding = 24.0;
  static const double iconSize = 80.0;
  static const double avatarRadius = 60.0;
  static const double avatarSize = 120.0;
  static const double borderRadius = 12.0;
  static const double buttonVerticalPadding = 16.0;
  static const double circularProgressStrokeWidth = 2.0;

  static const Duration pollingInterval = Duration(seconds: 1);
  static const Duration loginTimeout = Duration(seconds: 60);

  // TODO: Replace with your actual bot credentials
  static const String botId = '123456789';
  static const String botDomain = 'https://yourdomain.com';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telegram Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TelegramLoginScreen(),
    );
  }
}

class TelegramLoginScreen extends StatefulWidget {
  const TelegramLoginScreen({super.key});

  @override
  State<TelegramLoginScreen> createState() => _TelegramLoginScreenState();
}

class _TelegramLoginScreenState extends State<TelegramLoginScreen> {
  late final TextEditingController _phoneController;
  late final TelegramAuthClient _authClient;

  int _remainingSeconds = 0;
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '+');
    _authClient = TelegramAuthClient(
      config: TelegramConfig(
        botId: AppConstants.botId,
        botDomain: AppConstants.botDomain,
        pollingInterval: AppConstants.pollingInterval,
        timeout: AppConstants.loginTimeout,
        onProgress: _handleProgress,
        onError: _handleError,
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleProgress(int remaining) {
    if (!mounted) return;
    setState(() {
      _remainingSeconds = remaining;
      _statusMessage = 'Waiting for confirmation... $remaining seconds left';
    });
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    debugPrint('Auth Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  Future<void> _handleLogin() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty || phoneNumber == '+') {
      _showSnackBar('Please enter a phone number', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Initiating login...';
    });

    try {
      final result = await _authClient.login(phoneNumber);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess && result.user != null) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(user: result.user!),
          ),
        );
      } else {
        _showSnackBar(result.error ?? 'Unknown error', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Unexpected error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Login'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(context),
                  const SizedBox(height: 48),
                  _buildPhoneInput(),
                  const SizedBox(height: 24),
                  if (_isLoading && _statusMessage.isNotEmpty) _buildStatusMessage(),
                  if (!_isLoading) const SizedBox(height: 24),
                  if (!_isLoading) _buildLoginButton(),
                  const SizedBox(height: 24),
                  const _HowItWorksCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.telegram,
          size: AppConstants.iconSize,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        const Text(
          'Login with Telegram',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your phone number to continue',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '+1234567890',
        helperText: 'International format with country code',
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        focusColor: Colors.blue,
        enabled: !_isLoading,
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: AppConstants.circularProgressStrokeWidth,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_remainingSeconds > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Please open Telegram and confirm the login',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.buttonVerticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }
}

/// Info card explaining how the login process works
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 20),
              SizedBox(width: 8),
              Text(
                'How it works',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Enter your phone number\n'
            '2. We\'ll send a login request to your Telegram\n'
            '3. Open Telegram and confirm\n'
            '4. You\'ll be logged in automatically',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final TelegramUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _ProfileAvatar(user: user)),
              const SizedBox(height: 24),
              _UserInfoCard(user: user),
              const SizedBox(height: 24),
              const _SuccessMessage(),
              const Spacer(),
              _LogoutButton(onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}

/// User profile avatar with fallback support
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final TelegramUser user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: AppConstants.avatarRadius,
      backgroundColor: Colors.grey[300],
      child: user.photoUrl != null && user.photoUrl!.isNotEmpty
          ? _NetworkAvatarImage(
              photoUrl: user.photoUrl!,
              user: user,
            )
          : _FallbackAvatar(user: user),
    );
  }
}

/// Network image for avatar with loading and error handling
class _NetworkAvatarImage extends StatelessWidget {
  const _NetworkAvatarImage({
    required this.photoUrl,
    required this.user,
  });

  final String photoUrl;
  final TelegramUser user;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        photoUrl,
        width: AppConstants.avatarSize,
        height: AppConstants.avatarSize,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: AppConstants.circularProgressStrokeWidth,
              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Silently handle image loading errors with fallback UI
          return _FallbackAvatar(user: user);
        },
      ),
    );
  }
}

/// Fallback avatar showing user's initial
class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.user});

  final TelegramUser user;

  @override
  Widget build(BuildContext context) {
    final initial = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?';

    return Container(
      width: AppConstants.avatarSize,
      height: AppConstants.avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue[100],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w500,
            color: Colors.blue[800],
          ),
        ),
      ),
    );
  }
}

/// Card displaying user information
class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.user});

  final TelegramUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(label: 'Full Name', value: user.fullName),
            if (user.username != null) ...[
              const Divider(),
              _InfoRow(label: 'Username', value: '@${user.username}'),
            ],
            const Divider(),
            _InfoRow(label: 'User ID', value: user.id),
            if (user.authDate != null) ...[
              const Divider(),
              _InfoRow(
                label: 'Logged in',
                value: _formatDate(user.authDate!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Row displaying label and value
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Success message banner
class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Successfully authenticated with Telegram!',
              style: TextStyle(
                color: Colors.green.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logout button
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.buttonVerticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}

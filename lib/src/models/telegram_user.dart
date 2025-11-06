/// Telegram user information returned after successful authentication
class TelegramUser {
  /// Creates a [TelegramUser] from the given [data]
  const TelegramUser({
    required this.id,
    required this.firstName,
    this.lastName,
    this.username,
    this.photoUrl,
    this.authDate,
    this.hash,
    this.rawData,
  });

  /// Creates a [TelegramUser] from JSON map
  factory TelegramUser.fromJson(Map<String, dynamic> json) {
    return TelegramUser(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString(),
      username: json['username']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      authDate: json['auth_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(json['auth_date'].toString()) * 1000,
            )
          : null,
      hash: json['hash']?.toString(),
      rawData: Map<String, dynamic>.from(json),
    );
  }

  /// Telegram user ID
  final String id;

  /// User's first name
  final String firstName;

  /// User's last name (optional)
  final String? lastName;

  /// User's username (optional)
  final String? username;

  /// URL of user's profile photo (optional)
  final String? photoUrl;

  /// Authentication date
  final DateTime? authDate;

  /// Hash for verification
  final String? hash;

  /// Raw data from Telegram API
  final Map<String, dynamic>? rawData;

  /// Full name of the user
  String get fullName {
    if (lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  /// Converts this user to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (username != null) 'username': username,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (authDate != null) 'auth_date': (authDate!.millisecondsSinceEpoch / 1000).round(),
      if (hash != null) 'hash': hash,
    };
  }

  @override
  String toString() {
    return 'TelegramUser(id: $id, name: $fullName, username: $username)';
  }
}

class User {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String link;
  final String? avatarUrl;
  final String? lastActive;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    required this.link,
    this.avatarUrl,
    this.lastActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String? avatarUrl;

    // Extract avatar URL from HTML if present
    if (json['avatar'] != null && json['avatar'] is String) {
      final avatarHtml = json['avatar'] as String;
      final srcMatch = RegExp(r'src="([^"]+)"').firstMatch(avatarHtml);
      if (srcMatch != null) {
        avatarUrl = srcMatch.group(1);
      }
    } else if (json['avatar_url'] != null) {
      avatarUrl = json['avatar_url'];
    }

    return User(
      id: parseInt(json['id'] ?? json['user_id']),
      name: json['name'] ?? json['display_name'] ?? json['user_display_name'] ?? '',
      username: json['username'] ?? json['user_nicename'] ?? '',
      email: json['email'] ?? json['user_email'],
      link: json['link'] ?? json['profile_url'] ?? '',
      avatarUrl: avatarUrl,
      lastActive: json['last_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'link': link,
      'avatar_url': avatarUrl,
      'last_active': lastActive,
    };
  }
}

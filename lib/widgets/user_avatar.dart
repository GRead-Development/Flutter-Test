import 'package:flutter/material.dart';

/// Simple avatar widget that displays user initials
/// Note: Network avatars disabled due to CORS restrictions on Flutter web
class UserAvatar extends StatelessWidget {
  final int userId;
  final String displayName;
  final double radius;
  final bool useThumb;

  const UserAvatar({
    super.key,
    required this.userId,
    required this.displayName,
    this.radius = 20,
    this.useThumb = true,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        displayName.isNotEmpty
            ? displayName.substring(0, 1).toUpperCase()
            : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

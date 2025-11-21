import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/models/user.dart';
import 'package:gread_app/models/user_stats.dart';
import 'package:gread_app/services/api_service.dart';
import 'package:gread_app/providers/auth_provider.dart';
import 'package:gread_app/widgets/user_avatar.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? _user;
  UserStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService(token: authProvider.token);

      print('Loading user profile for userId: ${widget.userId}');
      final user = await apiService.getMember(widget.userId);
      print('User loaded: ${user.name}');

      final stats = await apiService.getUserStats(widget.userId);
      print('Stats loaded: ${stats.statistics.booksRead} books read');

      setState(() {
        _user = user;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user profile: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.name ?? 'User Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_user == null) {
      return const Center(
        child: Text('User not found'),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        UserAvatar(
          userId: _user!.id,
          displayName: _user!.name,
          radius: 50,
          useThumb: false, // Use full size for profile
        ),
        const SizedBox(height: 16),
        Text(
          _user!.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${_user!.username}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        if (_user!.lastActive != null) ...[
          const SizedBox(height: 4),
          Text(
            _user!.lastActive!,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
        const SizedBox(height: 32),
        if (_stats != null) _buildStats(_stats!),
      ],
    );
  }

  Widget _buildError() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Unable to load user profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(UserStats stats) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reading Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Books Completed',
                  stats.statistics.booksRead.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStatRow(
                  'Pages Read',
                  stats.statistics.pagesRead.toString(),
                  icon: Icons.menu_book,
                  color: Colors.blue,
                ),
                _buildStatRow(
                  'Books Added to DB',
                  stats.statistics.booksAddedToDb.toString(),
                  icon: Icons.add_circle,
                  color: Colors.purple,
                ),
                _buildStatRow(
                  'Points Earned',
                  stats.statistics.totalAchievementPoints.toString(),
                  icon: Icons.stars,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (stats.favoriteGenres.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Favorite Genres',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...stats.favoriteGenres
                      .map((genre) => _buildStatRow(
                            genre.genre,
                            '${genre.count} books',
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
        if (stats.statistics.memberSince != null) ...[
          const SizedBox(height: 16),
          Text(
            'Member since ${stats.statistics.memberSince}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value, {
    IconData? icon,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: color ?? Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

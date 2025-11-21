import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/providers/auth_provider.dart';
import 'package:gread_app/services/api_service.dart';
import 'package:gread_app/models/user_stats.dart';
import 'package:gread_app/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _error = 'User ID not available';
        });
        return;
      }

      final apiService = ApiService(token: authProvider.token);
      final stats = await apiService.getUserStats(userId);

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return RefreshIndicator(
            onRefresh: _loadStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (authProvider.userId != null)
                    UserAvatar(
                      userId: authProvider.userId!,
                      displayName: authProvider.displayName ?? authProvider.username ?? 'User',
                      radius: 50,
                      useThumb: false, // Use full size for profile
                    )
                  else
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        (authProvider.displayName ?? authProvider.username ?? 'U')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.displayName ?? authProvider.username ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${authProvider.username ?? 'username'}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (authProvider.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      authProvider.email!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_error != null)
                    _buildError()
                  else if (_stats != null)
                    _buildStats(_stats!)
                  else
                    _buildPlaceholderStats(),
                ],
              ),
            ),
          );
        },
      ),
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
              'Unable to load statistics',
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
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderStats() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reading Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildStatRow('Books Completed', '0'),
                _buildStatRow('Pages Read', '0'),
                _buildStatRow('Books Added', '0'),
                _buildStatRow('Points Earned', '0'),
                _buildStatRow('Currently Reading', '0'),
                _buildStatRow('Books in Library', '0'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(UserStats stats) {
    return Column(
      children: [
        // Main stats card
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
        // Favorite genres
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
        const SizedBox(height: 16),
        // Reading activity
        if (stats.readingActivity != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timeline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (stats.readingActivity!.last30Days != null) ...[
                    Text(
                      'Last 30 Days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'Books Completed',
                      stats.readingActivity!.last30Days!.booksCompleted
                          .toString(),
                    ),
                    _buildStatRow(
                      'Pages Read',
                      stats.readingActivity!.last30Days!.pagesRead.toString(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (stats.readingActivity!.thisYear != null) ...[
                    Text(
                      'This Year',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      'Books Completed',
                      stats.readingActivity!.thisYear!.booksCompleted
                          .toString(),
                    ),
                    _buildStatRow(
                      'Pages Read',
                      stats.readingActivity!.thisYear!.pagesRead.toString(),
                    ),
                  ],
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

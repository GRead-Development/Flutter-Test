import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/providers/auth_provider.dart';
import 'package:gread_app/services/api_service.dart';
import 'package:gread_app/models/user_stats.dart';

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
      final apiService = ApiService(token: authProvider.token);

      // Note: We would need the user ID. For now, we'll show a simplified version
      // In a real app, you'd get this from the JWT token or a separate endpoint

      setState(() {
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                  const CircularProgressIndicator()
                else if (_error != null)
                  Text('Error loading stats: $_error')
                else if (_stats != null)
                  _buildStats(_stats!)
                else
                  _buildPlaceholderStats(),
              ],
            ),
          );
        },
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
                _buildStatRow('Books Read', '0'),
                _buildStatRow('Pages Read', '0'),
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
                _buildStatRow(
                    'Books Read', stats.statistics.booksRead.toString()),
                _buildStatRow(
                    'Pages Read', stats.statistics.pagesRead.toString()),
                _buildStatRow('Currently Reading',
                    stats.statistics.currentlyReading.toString()),
                _buildStatRow('Books in Library',
                    stats.statistics.booksInLibrary.toString()),
                _buildStatRow('Reading Streak',
                    '${stats.statistics.readingStreakDays} days'),
                _buildStatRow('Achievements',
                    stats.statistics.achievementsUnlocked.toString()),
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
                  Text(
                    'Favorite Genres',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...stats.favoriteGenres
                      .map((genre) =>
                          _buildStatRow(genre.genre, genre.count.toString()))
                      .toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

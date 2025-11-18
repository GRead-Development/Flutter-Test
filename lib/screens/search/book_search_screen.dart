import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/providers/auth_provider.dart';
import 'package:gread_app/services/api_service.dart';
import 'package:gread_app/models/book.dart';
import 'package:gread_app/widgets/book_search_item.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final _searchController = TextEditingController();
  final _isbnController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  bool _isISBNSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService(token: authProvider.token);

      final results = await apiService.searchBooks(query);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _searchByISBN() async {
    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService(token: authProvider.token);

      final result = await apiService.lookupBookByISBN(isbn);

      setState(() {
        _searchResults = result != null ? [result] : [];
        _isLoading = false;
        if (result == null) {
          _error = 'No book found with ISBN: $isbn';
        }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Search'),
                            icon: Icon(Icons.search),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('ISBN'),
                            icon: Icon(Icons.qr_code),
                          ),
                        ],
                        selected: {_isISBNSearch},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            _isISBNSearch = newSelection.first;
                            _searchResults.clear();
                            _error = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!_isISBNSearch)
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search books by title or author...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _searchBooks,
                      ),
                    ),
                    onSubmitted: (_) => _searchBooks(),
                  )
                else
                  TextField(
                    controller: _isbnController,
                    decoration: InputDecoration(
                      hintText: 'Enter ISBN...',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _searchByISBN,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _searchByISBN(),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for Books',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search by title, author, or ISBN',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return BookSearchItem(book: _searchResults[index]);
      },
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:gread_app/models/book.dart';
import 'package:gread_app/services/api_service.dart';

class LibraryProvider with ChangeNotifier {
  final String? token;
  late final ApiService _apiService;

  List<LibraryBook> _books = [];
  bool _isLoading = false;
  String? _error;
  int _totalBooks = 0;
  int _reading = 0;
  int _completed = 0;
  int _wantToRead = 0;

  List<LibraryBook> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalBooks => _totalBooks;
  int get reading => _reading;
  int get completed => _completed;
  int get wantToRead => _wantToRead;

  LibraryProvider(this.token) {
    _apiService = ApiService(token: token);
    if (token != null) {
      loadLibrary();
    }
  }

  Future<void> loadLibrary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getLibrary();

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        final booksData = response['books'];
        if (booksData is List) {
          _books = booksData
              .map((json) => LibraryBook.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          _books = [];
        }

        _totalBooks = response['total_books'] ?? 0;
        _reading = response['reading'] ?? 0;
        _completed = response['completed'] ?? 0;
        _wantToRead = response['want_to_read'] ?? 0;
      } else if (response is List) {
        // Response is directly a list of books
        _books = response
            .map((json) => LibraryBook.fromJson(json as Map<String, dynamic>))
            .toList();
        _totalBooks = _books.length;
        _reading = _books.where((b) => b.status == 'reading').length;
        _completed = _books.where((b) => b.status == 'completed').length;
        _wantToRead = _books.where((b) => b.status == 'want_to_read').length;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBook(int bookId) async {
    try {
      await _apiService.addBookToLibrary(bookId);
      await loadLibrary();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgress(int bookId, int currentPage) async {
    try {
      await _apiService.updateReadingProgress(
        bookId: bookId,
        currentPage: currentPage,
      );
      await loadLibrary();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeBook(int bookId) async {
    try {
      await _apiService.removeBookFromLibrary(bookId);
      await loadLibrary();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await loadLibrary();
  }
}

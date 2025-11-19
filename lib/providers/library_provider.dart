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
      print('Library API Response: $response');

      // Handle different response formats
      if (response is Map<String, dynamic>) {
        final booksData = response['books'];
        print('Books data type: ${booksData.runtimeType}');
        print('Books data: $booksData');

        if (booksData is List) {
          _books = booksData
              .map((json) => LibraryBook.fromJson(json as Map<String, dynamic>))
              .toList();
          print('Parsed ${_books.length} books');
        } else {
          _books = [];
          print('Books data is not a List, setting empty');
        }

        _totalBooks = response['total_books'] ?? 0;
        _reading = response['reading'] ?? 0;
        _completed = response['completed'] ?? 0;
        _wantToRead = response['want_to_read'] ?? 0;
        print('Stats - Total: $_totalBooks, Reading: $_reading, Completed: $_completed, Want to Read: $_wantToRead');
      } else {
        // Fallback - empty library
        print('Response is not a Map, setting empty library');
        _books = [];
        _totalBooks = 0;
        _reading = 0;
        _completed = 0;
        _wantToRead = 0;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Library load error: $e');
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

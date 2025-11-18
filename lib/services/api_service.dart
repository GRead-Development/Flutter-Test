import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gread_app/config/api_config.dart';
import 'package:gread_app/models/user.dart';
import 'package:gread_app/models/activity.dart';
import 'package:gread_app/models/book.dart';
import 'package:gread_app/models/user_stats.dart';

class ApiService {
  final String? token;

  ApiService({this.token});

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get current user info
  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.buddypressBaseUrl}/members/me'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get current user: ${response.body}');
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.jwtTokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.greadBaseUrl}/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_login': username,
        'user_email': email,
        'password': password,
        'signup_field_data': [
          {
            'field_id': 1,
            'value': displayName ?? username,
            'visibility': 'public',
          }
        ],
      }),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // Activity
  Future<Map<String, dynamic>> getActivities({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/activity?page=$page&per_page=$perPage'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load activities: ${response.body}');
    }
  }

  Future<Activity> postActivity(String content) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.greadBaseUrl}/activity'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to post activity: ${response.body}');
    }
  }

  // Members
  Future<User> getMember(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/members/$userId'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load member: ${response.body}');
    }
  }

  Future<List<User>> getMembers({int page = 1, int perPage = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/members?page=$page&per_page=$perPage'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load members: ${response.body}');
    }
  }

  // User Stats
  Future<UserStats> getUserStats(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/user/$userId/stats'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return UserStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user stats: ${response.body}');
    }
  }

  // Library
  Future<Map<String, dynamic>> getLibrary() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/library'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load library: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> addBookToLibrary(int bookId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.greadBaseUrl}/library/add'),
      headers: _headers,
      body: jsonEncode({'book_id': bookId}),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add book to library: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateReadingProgress({
    required int bookId,
    required int currentPage,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.greadBaseUrl}/library/progress'),
      headers: _headers,
      body: jsonEncode({
        'book_id': bookId,
        'current_page': currentPage,
      }),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update progress: ${response.body}');
    }
  }

  Future<void> removeBookFromLibrary(int bookId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.greadBaseUrl}/library/remove?book_id=$bookId'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove book: ${response.body}');
    }
  }

  // Books
  Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/books/search?query=${Uri.encodeComponent(query)}'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books: ${response.body}');
    }
  }

  Future<Book> getBook(int bookId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/book/$bookId'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load book: ${response.body}');
    }
  }

  Future<Book?> lookupBookByISBN(String isbn) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/books/isbn?isbn=$isbn'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to lookup ISBN: ${response.body}');
    }
  }
}

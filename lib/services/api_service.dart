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

  Future<Activity> getSingleActivity(int activityId) async {
    // Use display_comments=stream to get comments included
    final url = '${ApiConfig.buddypressBaseUrl}/activity/$activityId?display_comments=stream';
    print('Fetching activity from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    print('Get single activity response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);

      // BuddyPress API returns array with single activity
      if (data is List && data.isNotEmpty) {
        final activity = data[0] as Map<String, dynamic>;
        // Ensure children is a list
        if (activity['children'] == null) {
          activity['children'] = [];
        } else if (activity['children'] is Map) {
          activity['children'] = [];
        }
        return Activity.fromJson(activity);
      } else {
        throw Exception('Unexpected activity response format: expected List, got ${data.runtimeType}');
      }
    } else {
      throw Exception('Failed to load activity: ${response.body}');
    }
  }

  Future<Activity> postActivity(String content) async {
    final url = '${ApiConfig.greadBaseUrl}/activity';
    print('Posting activity to: $url');
    print('Content: $content');
    print('Using token: ${token != null ? "Yes" : "No"}');

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode({'content': content}),
    ).timeout(ApiConfig.requestTimeout);

    print('Post activity response status: ${response.statusCode}');
    print('Post activity response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to post activity: ${response.body}');
    }
  }

  Future<Activity> postActivityComment(int activityId, String content) async {
    final url = '${ApiConfig.greadBaseUrl}/activity/$activityId/comment';
    print('Posting comment to activity $activityId');
    print('Comment content: $content');

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode({'content': content}),
    ).timeout(ApiConfig.requestTimeout);

    print('Post comment response status: ${response.statusCode}');
    print('Post comment response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to post comment: ${response.body}');
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

  Future<Map<String, String>> getMemberAvatar(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.buddypressBaseUrl}/members/$userId/avatar?html=false'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      // API returns an array with a single object containing full and thumb URLs
      final List<dynamic> dataList = jsonDecode(response.body);
      if (dataList.isNotEmpty && dataList[0] is Map<String, dynamic>) {
        final data = dataList[0] as Map<String, dynamic>;
        return {
          'full': data['full'] ?? '',
          'thumb': data['thumb'] ?? '',
        };
      }
      return {'full': '', 'thumb': ''};
    } else {
      throw Exception('Failed to load avatar: ${response.body}');
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
    final url = '${ApiConfig.greadBaseUrl}/user/$userId/stats';
    print('Fetching user stats from: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    print('User stats response status: ${response.statusCode}');
    print('User stats response body: ${response.body}');

    if (response.statusCode == 200) {
      return UserStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user stats: ${response.body}');
    }
  }

  // Library
  Future<Map<String, dynamic>> getLibrary() async {
    final url = '${ApiConfig.greadBaseUrl}/library';
    print('Fetching library from: $url');
    print('Using token: ${token != null ? "Yes (${token!.substring(0, 10)}...)" : "No"}');

    final response = await http.get(
      Uri.parse(url),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    print('Library response status: ${response.statusCode}');
    print('Library response body: ${response.body}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      print('Decoded response type: ${decodedResponse.runtimeType}');

      // Handle case where API returns a List instead of a Map
      if (decodedResponse is List) {
        print('Response is a List with ${decodedResponse.length} items');

        // Calculate stats from the book statuses
        int readingCount = 0;
        int completedCount = 0;
        int wantToReadCount = 0;

        for (var book in decodedResponse) {
          if (book is Map<String, dynamic>) {
            final status = book['status'] ?? '';
            if (status == 'reading') {
              readingCount++;
            } else if (status == 'completed') {
              completedCount++;
            } else if (status == 'want_to_read') {
              wantToReadCount++;
            }
          }
        }

        // Convert List response to expected Map format
        return {
          'books': decodedResponse,
          'total_books': decodedResponse.length,
          'reading': readingCount,
          'completed': completedCount,
          'want_to_read': wantToReadCount,
        };
      } else if (decodedResponse is Map<String, dynamic>) {
        print('Response is a Map');
        return decodedResponse;
      } else {
        throw Exception('Unexpected response format: ${decodedResponse.runtimeType}');
      }
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
    final url = '${ApiConfig.greadBaseUrl}/library/progress';
    print('Updating progress for book $bookId to page $currentPage');
    print('POST to: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode({
        'book_id': bookId,
        'current_page': currentPage,
      }),
    ).timeout(ApiConfig.requestTimeout);

    print('Update progress response status: ${response.statusCode}');
    print('Update progress response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update progress: ${response.body}');
    }
  }

  Future<void> removeBookFromLibrary(int bookId) async {
    final url = '${ApiConfig.greadBaseUrl}/library/remove?book_id=$bookId';
    print('Removing book $bookId from library');
    print('DELETE to: $url');

    final response = await http.delete(
      Uri.parse(url),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    print('Remove book response status: ${response.statusCode}');
    print('Remove book response body: ${response.body}');

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

  // Mentions
  Future<List<Map<String, dynamic>>> searchUsersForMention(String query) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.greadBaseUrl}/mentions/search?query=${Uri.encodeComponent(query)}&limit=10'),
      headers: _headers,
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> users = data['users'] ?? [];
      return users.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to search users: ${response.body}');
    }
  }
}

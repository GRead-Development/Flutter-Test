import 'package:flutter/foundation.dart';
import 'package:gread_app/models/activity.dart';
import 'package:gread_app/services/api_service.dart';

class ActivityProvider with ChangeNotifier {
  final String? token;
  late final ApiService _apiService;

  List<Activity> _activities = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _currentPage < _totalPages;

  ActivityProvider(this.token) {
    _apiService = ApiService(token: token);
    if (token != null) {
      loadActivities();
    }
  }

  Future<void> loadActivities({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _activities.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getActivities(
        page: _currentPage,
        perPage: 20,
      );

      // Handle different response formats
      List<Activity> newActivities = [];

      if (response['activities'] != null) {
        final activitiesData = response['activities'];
        if (activitiesData is List) {
          newActivities = activitiesData
              .map((json) => Activity.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (activitiesData is Map) {
          // Single activity wrapped in an object
          newActivities = [Activity.fromJson(activitiesData as Map<String, dynamic>)];
        }
      } else if (response is List) {
        // Response is directly a list of activities
        newActivities = response
            .map((json) => Activity.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      if (refresh) {
        _activities = newActivities;
      } else {
        _activities.addAll(newActivities);
      }

      _totalPages = (response is Map) ? (response['pages'] ?? 1) : 1;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_isLoading && hasMore) {
      _currentPage++;
      await loadActivities();
    }
  }

  Future<bool> postActivity(String content) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final activity = await _apiService.postActivity(content);
      _activities.insert(0, activity);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await loadActivities(refresh: true);
  }
}

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

      if (response is Map<String, dynamic>) {
        if (response['activities'] != null) {
          final activitiesData = response['activities'];
          if (activitiesData is List) {
            newActivities = activitiesData
                .map((json) => Activity.fromJson(json as Map<String, dynamic>))
                .where((activity) =>
                    activity.type == 'activity_update' ||
                    activity.type == 'activity_comment')
                .map((activity) {
                  // Sort children (comments) by date - oldest first
                  final sortedChildren = List<Activity>.from(activity.children);
                  sortedChildren.sort((a, b) => a.dateRecorded.compareTo(b.dateRecorded));
                  return Activity(
                    id: activity.id,
                    userId: activity.userId,
                    component: activity.component,
                    type: activity.type,
                    action: activity.action,
                    content: activity.content,
                    primaryLink: activity.primaryLink,
                    dateRecorded: activity.dateRecorded,
                    displayName: activity.displayName,
                    userFullname: activity.userFullname,
                    children: sortedChildren,
                  );
                })
                .toList();
          } else if (activitiesData is Map) {
            // Single activity wrapped in an object
            final activity = Activity.fromJson(activitiesData as Map<String, dynamic>);
            if (activity.type == 'activity_update' ||
                activity.type == 'activity_comment') {
              // Sort children (comments) by date - oldest first
              final sortedChildren = List<Activity>.from(activity.children);
              sortedChildren.sort((a, b) => a.dateRecorded.compareTo(b.dateRecorded));
              final updatedActivity = Activity(
                id: activity.id,
                userId: activity.userId,
                component: activity.component,
                type: activity.type,
                action: activity.action,
                content: activity.content,
                primaryLink: activity.primaryLink,
                dateRecorded: activity.dateRecorded,
                displayName: activity.displayName,
                userFullname: activity.userFullname,
                children: sortedChildren,
              );
              newActivities = [updatedActivity];
            }
          }
        }
        _totalPages = response['pages'] ?? 1;
      }

      if (refresh) {
        _activities = newActivities;
      } else {
        _activities.addAll(newActivities);
      }

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

  Future<bool> postComment(int activityId, String content) async {
    try {
      print('Posting comment to activity $activityId: $content');
      await _apiService.postActivityComment(activityId, content);
      print('Comment posted successfully, fetching updated activity...');

      // Re-fetch the activity to get the updated comments
      final updatedActivity = await _apiService.getSingleActivity(activityId);
      print('Fetched updated activity with ${updatedActivity.children.length} comments');

      // Find and update the activity in the list
      final activityIndex = _activities.indexWhere((a) => a.id == activityId);
      print('Found activity at index: $activityIndex');

      if (activityIndex != -1) {
        // Sort children (comments) by date - oldest first
        final sortedChildren = List<Activity>.from(updatedActivity.children);
        sortedChildren.sort((a, b) => a.dateRecorded.compareTo(b.dateRecorded));

        // Replace the activity with the updated one
        _activities[activityIndex] = Activity(
          id: updatedActivity.id,
          userId: updatedActivity.userId,
          component: updatedActivity.component,
          type: updatedActivity.type,
          action: updatedActivity.action,
          content: updatedActivity.content,
          primaryLink: updatedActivity.primaryLink,
          dateRecorded: updatedActivity.dateRecorded,
          displayName: updatedActivity.displayName,
          userFullname: updatedActivity.userFullname,
          children: sortedChildren,
        );

        print('Updated activity with ${sortedChildren.length} children, notifying listeners');
        notifyListeners();
      } else {
        print('WARNING: Could not find activity with id $activityId');
      }

      return true;
    } catch (e) {
      print('Error posting comment: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

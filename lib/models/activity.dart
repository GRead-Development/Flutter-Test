class Activity {
  final int id;
  final int userId;
  final String component;
  final String type;
  final String action;
  final String content;
  final String primaryLink;
  final String dateRecorded;
  final String displayName;
  final String userFullname;
  final List<Activity> children;

  Activity({
    required this.id,
    required this.userId,
    required this.component,
    required this.type,
    required this.action,
    required this.content,
    required this.primaryLink,
    required this.dateRecorded,
    required this.displayName,
    required this.userFullname,
    this.children = const [],
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        // WordPress/BuddyPress often returns {'rendered': 'actual content'}
        if (value.containsKey('rendered')) {
          return value['rendered']?.toString() ?? '';
        }
        return value.toString();
      }
      return value.toString();
    }

    // Parse children - handle both List and Map formats
    List<Activity> childrenList = [];
    final childrenData = json['children'];

    if (childrenData is List) {
      // Normal case: children is a list
      childrenList = childrenData
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (childrenData is Map) {
      // Edge case: children is a map/object, not a list
      // Skip or handle as needed - usually means no children
      childrenList = [];
    }

    return Activity(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id']),
      component: parseString(json['component']),
      type: parseString(json['type']),
      action: parseString(json['action']),
      content: parseString(json['content']),
      primaryLink: parseString(json['primary_link']),
      dateRecorded: parseString(json['date_recorded']),
      displayName: parseString(json['display_name']),
      userFullname: parseString(json['user_fullname']),
      children: childrenList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'component': component,
      'type': type,
      'action': action,
      'content': content,
      'primary_link': primaryLink,
      'date_recorded': dateRecorded,
      'display_name': displayName,
      'user_fullname': userFullname,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}

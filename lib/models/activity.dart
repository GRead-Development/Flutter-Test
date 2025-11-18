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
    return Activity(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      component: json['component'] ?? '',
      type: json['type'] ?? '',
      action: json['action'] ?? '',
      content: json['content'] ?? '',
      primaryLink: json['primary_link'] ?? '',
      dateRecorded: json['date_recorded'] ?? '',
      displayName: json['display_name'] ?? '',
      userFullname: json['user_fullname'] ?? '',
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

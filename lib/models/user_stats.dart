class UserStats {
  final int userId;
  final String username;
  final Statistics statistics;
  final List<GenreCount> favoriteGenres;
  final ReadingActivity? readingActivity;

  UserStats({
    required this.userId,
    required this.username,
    required this.statistics,
    this.favoriteGenres = const [],
    this.readingActivity,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    int parseUserId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Handle both nested statistics object and flat response
    final statisticsData = json['statistics'] as Map<String, dynamic>?;

    // If statistics object exists, use it; otherwise use flat structure
    final Statistics statistics;
    if (statisticsData != null) {
      statistics = Statistics.fromJson(statisticsData);
    } else {
      // Map flat response to Statistics object
      statistics = Statistics.fromJson({
        'books_read': json['books_completed'] ?? 0,
        'pages_read': json['pages_read'] ?? 0,
        'books_in_library': json['books_in_library'] ?? 0,
        'currently_reading': json['currently_reading'] ?? 0,
        'books_added_to_db': json['books_added'] ?? 0,
        'average_pages_per_book': json['average_pages_per_book'] ?? 0,
        'reading_streak_days': json['reading_streak_days'] ?? 0,
        'achievements_unlocked': json['achievements_unlocked'] ?? 0,
        'total_achievement_points': json['points'] ?? 0,
        'member_since': json['member_since'],
        'last_activity': json['last_activity'],
      });
    }

    return UserStats(
      userId: parseUserId(json['user_id']),
      username: json['username'] ?? json['display_name'] ?? '',
      statistics: statistics,
      favoriteGenres: (json['favorite_genres'] as List<dynamic>?)
              ?.map((e) => GenreCount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      readingActivity: json['reading_activity'] != null
          ? ReadingActivity.fromJson(json['reading_activity'])
          : null,
    );
  }
}

class Statistics {
  final int booksRead;
  final int pagesRead;
  final int booksInLibrary;
  final int currentlyReading;
  final int booksAddedToDb;
  final int averagePagesPerBook;
  final int readingStreakDays;
  final int achievementsUnlocked;
  final int totalAchievementPoints;
  final String? memberSince;
  final String? lastActivity;

  Statistics({
    this.booksRead = 0,
    this.pagesRead = 0,
    this.booksInLibrary = 0,
    this.currentlyReading = 0,
    this.booksAddedToDb = 0,
    this.averagePagesPerBook = 0,
    this.readingStreakDays = 0,
    this.achievementsUnlocked = 0,
    this.totalAchievementPoints = 0,
    this.memberSince,
    this.lastActivity,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Statistics(
      booksRead: parseInt(json['books_read']),
      pagesRead: parseInt(json['pages_read']),
      booksInLibrary: parseInt(json['books_in_library']),
      currentlyReading: parseInt(json['currently_reading']),
      booksAddedToDb: parseInt(json['books_added_to_db']),
      averagePagesPerBook: parseInt(json['average_pages_per_book']),
      readingStreakDays: parseInt(json['reading_streak_days']),
      achievementsUnlocked: parseInt(json['achievements_unlocked']),
      totalAchievementPoints: parseInt(json['total_achievement_points']),
      memberSince: json['member_since'],
      lastActivity: json['last_activity'],
    );
  }
}

class GenreCount {
  final String genre;
  final int count;

  GenreCount({required this.genre, required this.count});

  factory GenreCount.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return GenreCount(
      genre: json['genre'] ?? '',
      count: parseInt(json['count']),
    );
  }
}

class ReadingActivity {
  final PeriodStats? last30Days;
  final PeriodStats? thisYear;

  ReadingActivity({this.last30Days, this.thisYear});

  factory ReadingActivity.fromJson(Map<String, dynamic> json) {
    return ReadingActivity(
      last30Days: json['last_30_days'] != null
          ? PeriodStats.fromJson(json['last_30_days'])
          : null,
      thisYear: json['this_year'] != null
          ? PeriodStats.fromJson(json['this_year'])
          : null,
    );
  }
}

class PeriodStats {
  final int booksCompleted;
  final int pagesRead;

  PeriodStats({required this.booksCompleted, required this.pagesRead});

  factory PeriodStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return PeriodStats(
      booksCompleted: parseInt(json['books_completed']),
      pagesRead: parseInt(json['pages_read']),
    );
  }
}

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
    return UserStats(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      statistics: Statistics.fromJson(json['statistics'] ?? {}),
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
    return Statistics(
      booksRead: json['books_read'] ?? 0,
      pagesRead: json['pages_read'] ?? 0,
      booksInLibrary: json['books_in_library'] ?? 0,
      currentlyReading: json['currently_reading'] ?? 0,
      booksAddedToDb: json['books_added_to_db'] ?? 0,
      averagePagesPerBook: json['average_pages_per_book'] ?? 0,
      readingStreakDays: json['reading_streak_days'] ?? 0,
      achievementsUnlocked: json['achievements_unlocked'] ?? 0,
      totalAchievementPoints: json['total_achievement_points'] ?? 0,
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
    return GenreCount(
      genre: json['genre'] ?? '',
      count: json['count'] ?? 0,
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
    return PeriodStats(
      booksCompleted: json['books_completed'] ?? 0,
      pagesRead: json['pages_read'] ?? 0,
    );
  }
}

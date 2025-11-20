class Book {
  final int id;
  final String title;
  final String author;
  final String? isbn;
  final int? pageCount;
  final String? description;
  final String? coverImage;
  final String? permalink;
  final String? publicationYear;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.pageCount,
    this.description,
    this.coverImage,
    this.permalink,
    this.publicationYear,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? parseIntOrNull(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Book(
      id: parseInt(json['id'] ?? json['book_id']),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'],
      pageCount: parseIntOrNull(json['page_count']),
      description: json['description'] ?? json['content'],
      coverImage: json['cover_image'],
      permalink: json['permalink'],
      publicationYear: json['publication_year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'page_count': pageCount,
      'description': description,
      'cover_image': coverImage,
      'permalink': permalink,
      'publication_year': publicationYear,
    };
  }
}

class LibraryBook extends Book {
  final int currentPage;
  final double progressPercentage;
  final String status;
  final String? addedDate;
  final String? lastUpdated;

  LibraryBook({
    required super.id,
    required super.title,
    required super.author,
    super.isbn,
    super.pageCount,
    super.description,
    super.coverImage,
    super.permalink,
    super.publicationYear,
    required this.currentPage,
    required this.progressPercentage,
    required this.status,
    this.addedDate,
    this.lastUpdated,
  });

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Handle nested book structure from API
    final bookData = json['book'] as Map<String, dynamic>?;
    final useNestedStructure = bookData != null;

    final int pageCount = useNestedStructure
        ? parseInt(bookData['page_count'])
        : parseInt(json['page_count']);
    final int currentPage = parseInt(json['current_page']);

    // Calculate progress percentage if not provided
    double progressPercentage = (json['progress_percentage'] ?? 0.0).toDouble();
    if (progressPercentage == 0.0 && pageCount > 0 && currentPage > 0) {
      progressPercentage = (currentPage / pageCount * 100).clamp(0.0, 100.0);
    }

    // Auto-determine status based on progress
    String status = json['status'] ?? 'want_to_read';
    if (pageCount > 0 && currentPage >= pageCount) {
      status = 'completed';
    } else if (currentPage > 0 && status == 'want_to_read') {
      status = 'reading';
    }

    return LibraryBook(
      id: useNestedStructure
          ? parseInt(bookData['id'])
          : parseInt(json['book_id'] ?? json['id']),
      title: useNestedStructure
          ? (bookData['title'] ?? '')
          : (json['title'] ?? ''),
      author: useNestedStructure
          ? (bookData['author'] ?? '')
          : (json['author'] ?? ''),
      isbn: useNestedStructure ? bookData['isbn'] : json['isbn'],
      pageCount: pageCount,
      description: useNestedStructure
          ? (bookData['description'] ?? bookData['content'])
          : (json['description'] ?? json['content']),
      coverImage: useNestedStructure ? bookData['cover_image'] : json['cover_image'],
      permalink: useNestedStructure ? bookData['permalink'] : json['permalink'],
      publicationYear: useNestedStructure ? bookData['publication_year'] : json['publication_year'],
      currentPage: currentPage,
      progressPercentage: progressPercentage,
      status: status,
      addedDate: json['added_date'],
      lastUpdated: json['last_updated'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'current_page': currentPage,
      'progress_percentage': progressPercentage,
      'status': status,
      'added_date': addedDate,
      'last_updated': lastUpdated,
    });
    return json;
  }
}

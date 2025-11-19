class BookMention {
  final int bookId;
  final String bookTitle;
  final int startIndex;
  final int endIndex;

  BookMention({
    required this.bookId,
    required this.bookTitle,
    required this.startIndex,
    required this.endIndex,
  });
}

class BookMentionParser {
  static final RegExp _bookMentionRegex =
      RegExp(r'#\[book-id-(\d+):([^\]]+)\]');

  static List<BookMention> parseBookMentions(String text) {
    final List<BookMention> mentions = [];
    final matches = _bookMentionRegex.allMatches(text);

    for (final match in matches) {
      final bookId = int.tryParse(match.group(1) ?? '');
      final bookTitle = match.group(2);

      if (bookId != null && bookTitle != null) {
        mentions.add(BookMention(
          bookId: bookId,
          bookTitle: bookTitle,
          startIndex: match.start,
          endIndex: match.end,
        ));
      }
    }

    return mentions;
  }

  static String replaceBookMentionsWithTitles(String text) {
    return text.replaceAllMapped(_bookMentionRegex, (match) {
      return match.group(2) ?? match.group(0) ?? '';
    });
  }
}

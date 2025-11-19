class HtmlUtils {
  static String stripHtml(String html) {
    // Remove HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove backslash escaping (WordPress adds these)
    text = text.replaceAll(r'\"', '"').replaceAll(r"\'", "'");

    // Decode common HTML entities
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&apos;', "'");

    return text.trim();
  }

  static String extractUrl(String html, {String attribute = 'href'}) {
    final regex = RegExp('$attribute="([^"]*)"');
    final match = regex.firstMatch(html);
    return match?.group(1) ?? '';
  }
}

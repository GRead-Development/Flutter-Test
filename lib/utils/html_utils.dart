class HtmlUtils {
  static String stripHtml(String html) {
    // Remove HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove backslash escaping (WordPress adds these)
    text = text.replaceAll(r'\"', '"').replaceAll(r"\'", "'");

    // Decode numeric HTML entities (&#8217;, &#x2019;, etc.)
    text = text.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final charCode = int.tryParse(match.group(1)!);
      return charCode != null ? String.fromCharCode(charCode) : match.group(0)!;
    });

    text = text.replaceAllMapped(RegExp(r'&#[xX]([0-9a-fA-F]+);'), (match) {
      final charCode = int.tryParse(match.group(1)!, radix: 16);
      return charCode != null ? String.fromCharCode(charCode) : match.group(0)!;
    });

    // Decode common named HTML entities
    text = text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&apos;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ldquo;', '"')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '…');

    return text.trim();
  }

  static String extractUrl(String html, {String attribute = 'href'}) {
    final regex = RegExp('$attribute="([^"]*)"');
    final match = regex.firstMatch(html);
    return match?.group(1) ?? '';
  }
}

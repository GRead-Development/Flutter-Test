import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/utils/book_mention_parser.dart';
import 'package:gread_app/services/api_service.dart';
import 'package:gread_app/providers/auth_provider.dart';
import 'package:gread_app/models/book.dart';

class ActivityContentWithMentions extends StatelessWidget {
  final String content;
  final double fontSize;

  const ActivityContentWithMentions({
    super.key,
    required this.content,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    final mentions = BookMentionParser.parseBookMentions(content);

    if (mentions.isEmpty) {
      // No mentions, just display plain text
      return Text(
        content,
        style: TextStyle(fontSize: fontSize),
      );
    }

    // Build rich text with clickable book mentions
    final List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final mention in mentions) {
      // Add text before the mention
      if (mention.startIndex > currentIndex) {
        spans.add(TextSpan(
          text: content.substring(currentIndex, mention.startIndex),
        ));
      }

      // Add clickable book mention
      spans.add(TextSpan(
        text: mention.bookTitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => _showBookDetails(context, mention.bookId),
      ));

      currentIndex = mention.endIndex;
    }

    // Add remaining text after the last mention
    if (currentIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(currentIndex),
      ));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, color: Colors.black87),
        children: spans,
      ),
    );
  }

  Future<void> _showBookDetails(BuildContext context, int bookId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService(token: authProvider.token);
      final book = await apiService.getBook(bookId);

      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show book details dialog
      _showBookDetailsDialog(context, book);
    } catch (e) {
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load book details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBookDetailsDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (book.coverImage != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.coverImage!,
                      height: 200,
                      errorBuilder: (_, __, ___) => Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Author', book.author),
              if (book.isbn != null) _buildDetailRow('ISBN', book.isbn!),
              if (book.pageCount != null)
                _buildDetailRow('Pages', book.pageCount.toString()),
              if (book.publicationYear != null)
                _buildDetailRow('Published', book.publicationYear!),
              if (book.description != null &&
                  book.description != 'No description available.') ...[
                const SizedBox(height: 8),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(book.description!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

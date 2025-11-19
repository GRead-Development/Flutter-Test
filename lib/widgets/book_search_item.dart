import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/models/book.dart';
import 'package:gread_app/providers/library_provider.dart';

class BookSearchItem extends StatelessWidget {
  final Book book;
  final bool selectMode;

  const BookSearchItem({
    super.key,
    required this.book,
    this.selectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: book.coverImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                book.coverImage!,
                width: 50,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
      title: Text(
        book.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(book.author),
          if (book.isbn != null) ...[
            const SizedBox(height: 2),
            Text(
              'ISBN: ${book.isbn}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          if (book.pageCount != null) ...[
            const SizedBox(height: 2),
            Text(
              '${book.pageCount} pages',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
      trailing: selectMode
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : ElevatedButton.icon(
              onPressed: () => _addToLibrary(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
      onTap: selectMode ? () => _selectBook(context) : () => _showBookDetails(context),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 50,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _selectBook(BuildContext context) {
    Navigator.pop(context, {
      'id': book.id,
      'title': book.title,
    });
  }

  void _addToLibrary(BuildContext context) async {
    final provider = Provider.of<LibraryProvider>(context, listen: false);
    final success = await provider.addBook(book.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Book added to library'
              : provider.error ?? 'Failed to add book'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showBookDetails(BuildContext context) {
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
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
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
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _addToLibrary(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add to Library'),
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

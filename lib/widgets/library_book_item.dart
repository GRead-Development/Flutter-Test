import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/models/book.dart';
import 'package:gread_app/providers/library_provider.dart';

class LibraryBookItem extends StatelessWidget {
  final LibraryBook book;

  const LibraryBookItem({super.key, required this.book});

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
          const SizedBox(height: 8),
          if (book.pageCount != null && book.pageCount! > 0) ...[
            LinearProgressIndicator(
              value: book.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 4),
            Text(
              '${book.currentPage} / ${book.pageCount} pages (${book.progressPercentage.toStringAsFixed(1)}%)',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 4),
          _buildStatusChip(context),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleAction(context, value),
        itemBuilder: (context) => [
          if (book.status == 'reading')
            const PopupMenuItem(
              value: 'update_progress',
              child: Text('Update Progress'),
            ),
          const PopupMenuItem(
            value: 'remove',
            child: Text('Remove from Library'),
          ),
        ],
      ),
      onTap: () => _showBookDetails(context),
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

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String label;

    switch (book.status) {
      case 'reading':
        color = Colors.green;
        label = 'Reading';
        break;
      case 'completed':
        color = Colors.purple;
        label = 'Completed';
        break;
      case 'want_to_read':
        color = Colors.orange;
        label = 'To Read';
        break;
      default:
        color = Colors.grey;
        label = book.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    final provider = Provider.of<LibraryProvider>(context, listen: false);

    switch (action) {
      case 'update_progress':
        _showProgressDialog(context);
        break;
      case 'remove':
        _showRemoveDialog(context, provider);
        break;
    }
  }

  void _showProgressDialog(BuildContext context) {
    final controller = TextEditingController(text: book.currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Current Page',
                hintText: 'Enter page number',
                suffixText: '/ ${book.pageCount ?? '?'}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final page = int.tryParse(controller.text);
              if (page != null) {
                final provider =
                    Provider.of<LibraryProvider>(context, listen: false);
                final success = await provider.updateProgress(book.id, page);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Progress updated'
                          : 'Failed to update progress'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, LibraryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Book'),
        content: Text('Remove "${book.title}" from your library?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.removeBook(book.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        success ? 'Book removed' : 'Failed to remove book'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
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

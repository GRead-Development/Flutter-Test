import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/providers/activity_provider.dart';
import 'package:gread_app/providers/auth_provider.dart';
import 'package:gread_app/services/api_service.dart';
import 'package:gread_app/screens/search/book_search_screen.dart';

class NewActivityScreen extends StatefulWidget {
  const NewActivityScreen({super.key});

  @override
  State<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  List<Map<String, dynamic>> _mentionSuggestions = [];
  bool _showMentionSuggestions = false;
  String _currentMentionQuery = '';
  int _mentionStartPosition = -1;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _contentController.text;
    final cursorPosition = _contentController.selection.baseOffset;

    if (cursorPosition < 0) return;

    // Find @ symbol before cursor
    int atIndex = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atIndex = i;
        break;
      }
      if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (atIndex >= 0) {
      final query = text.substring(atIndex + 1, cursorPosition);
      if (query.isEmpty || !query.contains(' ')) {
        _mentionStartPosition = atIndex;
        _currentMentionQuery = query;
        _searchUsers(query);
        return;
      }
    }

    // Hide suggestions if not in mention mode
    if (_showMentionSuggestions) {
      setState(() {
        _showMentionSuggestions = false;
        _mentionSuggestions = [];
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showMentionSuggestions = false;
        _mentionSuggestions = [];
      });
      return;
    }

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final apiService = ApiService(token: authProvider.token);
      final users = await apiService.searchUsersForMention(query);

      setState(() {
        _mentionSuggestions = users;
        _showMentionSuggestions = users.isNotEmpty;
      });
    } catch (e) {
      // Silently fail - mentions are not critical
      setState(() {
        _showMentionSuggestions = false;
        _mentionSuggestions = [];
      });
    }
  }

  void _insertMention(Map<String, dynamic> user) {
    final String username = user['username'] ?? '';
    final text = _contentController.text;
    final newText = text.substring(0, _mentionStartPosition) +
        '@$username ' +
        text.substring(_contentController.selection.baseOffset);

    final int newCursorPosition = (_mentionStartPosition + username.length + 2) as int;

    // Unfocus first to prevent Flutter web focus conflicts
    _focusNode.unfocus();

    setState(() {
      _showMentionSuggestions = false;
      _mentionSuggestions = [];
    });

    // Update text after unfocusing
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  void _insertBookMention(int bookId, String bookTitle) {
    print('_insertBookMention called with bookId: $bookId, title: $bookTitle');
    final int cursorPosition = _contentController.selection.baseOffset;
    final text = _contentController.text;
    final String mention = '#[book-id-$bookId:$bookTitle]';

    print('Current text: "$text", cursor at: $cursorPosition');
    print('Mention to insert: "$mention"');

    final newText = text.substring(0, cursorPosition) +
        mention +
        ' ' +
        text.substring(cursorPosition);

    final int newCursorPosition = (cursorPosition + mention.length + 1) as int;

    print('New text: "$newText", new cursor at: $newCursorPosition');

    // Update text controller
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  Future<void> _showBookMentionDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookSearchScreen(selectMode: true),
      ),
    );

    print('Book selection result: $result');

    if (result != null && result is Map<String, dynamic>) {
      final bookId = result['id'];
      final bookTitle = result['title'];
      print('Book ID: $bookId, Title: $bookTitle');
      if (bookId != null && bookTitle != null) {
        _insertBookMention(bookId, bookTitle);
      }
    }
  }

  Future<void> _postActivity() async {
    final content = _contentController.text.trim();
    print('Attempting to post activity with content: $content');

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    print('Content is not empty, calling provider.postActivity...');
    final provider = Provider.of<ActivityProvider>(context, listen: false);
    final success = await provider.postActivity(content);

    print('Post activity result: $success');
    if (!mounted) return;

    if (success) {
      print('Post successful, closing screen');
      Navigator.of(context).pop(true);
    } else {
      print('Post failed with error: ${provider.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to post activity'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            tooltip: 'Mention a book',
            onPressed: _showBookMentionDialog,
          ),
          Consumer<ActivityProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: provider.isLoading ? null : _postActivity,
                child: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind? Share a book update...',
                  border: InputBorder.none,
                ),
              ),
            ),
            if (_showMentionSuggestions)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _mentionSuggestions.length,
                  itemBuilder: (context, index) {
                    final user = _mentionSuggestions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user['avatar_url'] != null
                            ? NetworkImage(user['avatar_url'])
                            : null,
                        child: user['avatar_url'] == null
                            ? Text(
                                (user['display_name'] ?? '?')[0]
                                    .toUpperCase())
                            : null,
                      ),
                      title: Text(user['display_name'] ?? ''),
                      subtitle: Text('@${user['username'] ?? ''}'),
                      onTap: () => _insertMention(user),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Mention users: Type @ to search users',
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                  Text(
                    '• Mention books: #[book-id-123:Book Title]',
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

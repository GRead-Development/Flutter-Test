import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gread_app/models/activity.dart';
import 'package:gread_app/utils/html_utils.dart';
import 'package:gread_app/utils/date_utils.dart' as app_date_utils;
import 'package:gread_app/widgets/activity_content_with_mentions.dart';
import 'package:gread_app/providers/activity_provider.dart';
import 'package:gread_app/screens/profile/user_profile_screen.dart';

class ActivityItem extends StatefulWidget {
  final Activity activity;

  const ActivityItem({super.key, required this.activity});

  @override
  State<ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<ActivityItem> {
  bool _showCommentInput = false;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = Provider.of<ActivityProvider>(context, listen: false);
    final success = await provider.postComment(
      widget.activity.id,
      _commentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _commentController.clear();
      setState(() {
        _showCommentInput = false;
        _isSubmitting = false;
      });
    } else {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Failed to post comment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: widget.activity.userId),
      ),
    );
  }

  void _navigateToCommentUserProfile(BuildContext context, int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => _navigateToUserProfile(context),
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      widget.activity.userFullname.isNotEmpty
                          ? widget.activity.userFullname.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _navigateToUserProfile(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activity.userFullname,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          app_date_utils.formatActivityDate(widget.activity.dateRecorded),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ActivityContentWithMentions(
              content: HtmlUtils.stripHtml(widget.activity.content),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showCommentInput = !_showCommentInput;
                    });
                  },
                  icon: const Icon(Icons.comment_outlined, size: 18),
                  label: Text(widget.activity.children.isEmpty
                      ? 'Comment'
                      : '${widget.activity.children.length} comments'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            if (_showCommentInput) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
            if (widget.activity.children.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...widget.activity.children.map((comment) => _buildComment(comment)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComment(Activity comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 32, top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _navigateToCommentUserProfile(context, comment.userId),
                    borderRadius: BorderRadius.circular(12),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        comment.userFullname.isNotEmpty
                            ? comment.userFullname.substring(0, 1).toUpperCase()
                            : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _navigateToCommentUserProfile(context, comment.userId),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.userFullname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            app_date_utils.formatActivityDate(comment.dateRecorded),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ActivityContentWithMentions(
                content: HtmlUtils.stripHtml(comment.content),
                fontSize: 14,
              ),
            ],
          ),
        ),
        // Show nested replies if any
        if (comment.children.isNotEmpty) ...[
          ...comment.children.map((reply) => _buildNestedComment(reply)),
        ],
      ],
    );
  }

  Widget _buildNestedComment(Activity reply) {
    return Container(
      margin: const EdgeInsets.only(left: 64, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[25],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => _navigateToCommentUserProfile(context, reply.userId),
                borderRadius: BorderRadius.circular(10),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: Text(
                    reply.userFullname.isNotEmpty
                        ? reply.userFullname.substring(0, 1).toUpperCase()
                        : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _navigateToCommentUserProfile(context, reply.userId),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reply.userFullname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        app_date_utils.formatActivityDate(reply.dateRecorded),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ActivityContentWithMentions(
            content: HtmlUtils.stripHtml(reply.content),
            fontSize: 13,
          ),
        ],
      ),
    );
  }
}

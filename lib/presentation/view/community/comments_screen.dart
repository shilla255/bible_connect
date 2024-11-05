
import 'package:bible/presentation/view/community/report/report_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/post_model.dart';
import '../../../data/models/comment.dart';
import '../../../data/models/user.dart';
import 'package:timeago/timeago.dart' as timeago;


class CommentScreen extends ConsumerStatefulWidget {
  final Post post;
  final String currentUserId;
  final String currentUsername;

  const CommentScreen({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _isLoading = false;
  Comment? _replyingTo;
  final Map<String, GlobalKey> _commentKeys = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newComment = Comment(
        userId: widget.currentUserId,
        username: widget.currentUsername,
        content: _commentController.text.trim(),
        timestamp: DateTime.now(),
        likes: [],
        replies: [],
        replyTo: _replyingTo, commentId: '',
      );

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.postId)
          .update({
        'comments': FieldValue.arrayUnion([newComment.toMap()])
      });

      setState(() {
        widget.post.comments.add(newComment);
        _commentController.clear();
        _replyingTo = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _replyToComment(Comment comment) {
    setState(() {
      _replyingTo = comment;
    });
    final key = _commentKeys[comment.commentId];
    if (key != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(seconds: 1));
    }
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text("Comments",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[700]!, Colors.indigo[100]!],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                key: _listKey,
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  final comment = widget.post.comments[index];
                  final commentKey = GlobalKey();
                  _commentKeys[comment.commentId] = commentKey;
                  return _buildCommentCard(comment, commentKey);
                },
              ),
            ),
            if (_replyingTo != null) _buildReplyingToBar(),
            _buildCommentInputBar(),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReportDialog(
          postId: widget.post.postId,
          currentUserId: widget.currentUserId,
          reporterId: widget.currentUserId,
          reportedUserId: commentId,
        );
      },
    );
  }

  Future<CustomUser?> _fetchUser(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      return CustomUser.fromMap(doc.data()!);
    }
    return null;
  }

  Widget _buildCommentCard(Comment comment, GlobalKey key) {
    final theme = Theme.of(context);
    return FutureBuilder<CustomUser?>(
      future: _fetchUser(comment.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Card(
          key: key,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (comment.replyTo != null) _buildReplyToContainer(comment.replyTo!),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.secondary,
                      child: Text(
                        comment.username[0].toUpperCase(),
                        style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.username,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: theme.textTheme.bodyLarge?.color),
                              ),
                              if (user != null && user.isVerified) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.verified, color: Colors.blue, size: 16,),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            comment.content,
                            style: TextStyle(fontSize: 14.0, color: theme.textTheme.bodyMedium?.color),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'Report') {
                          _showReportDialog(comment.userId);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Report'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeago.format(comment.timestamp),
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12.0),
                    ),
                    TextButton.icon(
                      onPressed: () => _replyToComment(comment),
                      icon: const Icon(Icons.reply, size: 16.0),
                      label: const Text("Reply", style: TextStyle(fontSize: 12.0)),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildReplyToContainer(Comment replyTo) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${replyTo.username}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            replyTo.content,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 12.0,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyingToBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.secondary.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to @${_replyingTo!.username}',
                  style: TextStyle(fontStyle: FontStyle.italic, color: theme.colorScheme.primary, fontSize: 12.0),
                ),
                Text(
                  _replyingTo!.content,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: theme.textTheme.bodyLarge?.color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _cancelReply,
            child: Icon(CupertinoIcons.clear, color: theme.colorScheme.onSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: null, // Allows the TextField to expand
              maxLength: 300, // Sets the maximum character limit
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                prefixIcon: Icon(Icons.comment, color: theme.colorScheme.secondary),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(width: 12.0),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: _isLoading ? theme.disabledColor : theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.onPrimary,
                strokeWidth: 2.0,
              ),
            )
                : IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.onPrimary),
              onPressed: _addComment,
            ),
          ),
        ],
      ),
    );
  }
}
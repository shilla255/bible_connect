import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/user.dart';
import '../comments_screen.dart';
import '../report/report_dialog.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final String currentUserId;
  final String currentUsername;

  const PostWidget({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.currentUsername,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with SingleTickerProviderStateMixin {
  late bool isLiked;
  late bool isBookmarked;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize isBookmarked to false
    isBookmarked = false;

    // Check if the current user has liked the post
    isLiked = widget.post.likes.contains(widget.currentUserId);

    // Assume bookmark status is fetched from Firestore
    _checkBookmarkStatus();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkBookmarkStatus() async {
    final bookmarkRef = _firestore
        .collection('users')
        .doc(widget.currentUserId)
        .get();

    final bookmarkSnapshot = await bookmarkRef;

    if (bookmarkSnapshot.exists) {
      final data = bookmarkSnapshot.data();
      setState(() {
        isBookmarked = data?['bookmarks'] != null && (data?['bookmarks'] as List).contains(widget.post.postId);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Toggle the like status and update Firestore
  void _toggleLike() async {
    setState(() {
      isLiked = !isLiked;
    });

    if (isLiked) {
      _animationController.forward().then((_) => _animationController.reverse());
      await widget.post.likePost(widget.currentUserId); // Update Firestore with the like
    } else {
      await widget.post.unlikePost(widget.currentUserId); // Update Firestore to remove the like
    }
  }

  // Toggle bookmark status and update Firestore
  Future<void> _toggleBookmark() async {
    try {
      final userRef = _firestore.collection('users').doc(widget.currentUserId);

      // Start a transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userRef);

        if (!userSnapshot.exists) {
          throw Exception('User document not found');
        }

        final userData = userSnapshot.data();
        List<String> bookmarks = List<String>.from(userData?['bookmarks'] ?? []);

        if (isBookmarked) {
          bookmarks.remove(widget.post.postId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post removed from bookmarks!'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          if (!bookmarks.contains(widget.post.postId)) {
            bookmarks.add(widget.post.postId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post bookmarked!'),
                backgroundColor: Colors.purple,
              ),
            );
          }
        }

        transaction.update(userRef, {'bookmarks': bookmarks});
      });

      setState(() {
        isBookmarked = !isBookmarked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentScreen(
          post: widget.post,
          currentUserId: widget.currentUserId,
          currentUsername: widget.currentUsername,
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReportDialog(
          postId: widget.post.postId,
          reporterId: widget.currentUserId,
          reportedUserId: widget.post.userId, currentUserId: '',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<CustomUser?>(
      future: _fetchUser(widget.post.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Container(
          width: double.infinity, // Full width
          constraints: const BoxConstraints(
            minHeight: 250, // Minimum height
            maxHeight: 300, // Maximum height to maintain consistency
          ),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.colorScheme.surface, theme.scaffoldBackgroundColor],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header section with user info and menu
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondary,
                                  child: Text(
                                    widget.post.username[0].toUpperCase(),
                                    style: TextStyle(color: theme.colorScheme.onSecondary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Row(
                                  children: [
                                    Text(
                                      widget.post.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: theme.textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    if (user != null && user.isVerified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                              onSelected: (value) {
                                if (value == 'Report') {
                                  _showReportDialog();
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
                      ),

                      // Content section
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.post.content,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action buttons section with divider
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Like button and count
                                Row(
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: _toggleLike,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ScaleTransition(
                                            scale: _scaleAnimation,
                                            child: Icon(
                                              Icons.favorite,
                                              size: 24,
                                              color: isLiked ? Colors.red.shade400 : theme.iconTheme.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${widget.post.likeCount}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Comment button and count
                                Row(
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: _navigateToComments,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            CupertinoIcons.chat_bubble,
                                            size: 24,
                                            color: theme.iconTheme.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${widget.post.comments.length}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                // Bookmark button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: _toggleBookmark,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                        size: 24,
                                        color: theme.iconTheme.color,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

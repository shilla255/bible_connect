import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/post_model.dart';
import '../community_widgets/post_widget.dart';
import '../../../../data/models/user.dart' as custom;

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  Future<List<Post>> _fetchBookmarkedPosts(String userId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final bookmarks = List<String>.from(userSnapshot.data()?['bookmarks'] ?? []);
        final List<Post> bookmarkedPosts = [];

        for (String postId in bookmarks) {
          final postSnapshot = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
          if (postSnapshot.exists) {
            bookmarkedPosts.add(Post.fromMap(postSnapshot.data()!, postSnapshot.id));
          }
        }
        return bookmarkedPosts;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching bookmarks: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final firebaseUser = authSnapshot.data;
          if (firebaseUser == null) {
            return const Center(child: Text('Please log in to view bookmarks'));
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(firebaseUser.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${userSnapshot.error}'),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(child: Text('User profile not found'));
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              final customUser = custom.CustomUser.fromMap(userData);

              return FutureBuilder<List<Post>>(
                future: _fetchBookmarkedPosts(firebaseUser.uid),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (postSnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${postSnapshot.error}'),
                    );
                  } else if (!postSnapshot.hasData || postSnapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No bookmarked posts yet.'),
                    );
                  } else {
                    final bookmarkedPosts = postSnapshot.data!;
                    return ListView.builder(
                      itemCount: bookmarkedPosts.length,
                      itemBuilder: (context, index) {
                        final post = bookmarkedPosts[index];
                        return PostWidget(
                          post: post,
                          currentUserId: firebaseUser.uid,
                          currentUsername: customUser.username,
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
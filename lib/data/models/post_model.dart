import 'package:cloud_firestore/cloud_firestore.dart';
import 'comment.dart';

class Post {
  final String postId;
  final String userId;
  final String username;
  final String title;
  final String content;
  final List<String> likes; // Store user IDs who liked the post
  final int likeCount;
  final List<Comment> comments;
  final DateTime timestamp;
  final GeoPoint? location; // Added field for post location

  Post({
    required this.postId,
    required this.userId,
    required this.username,
    required this.title,
    required this.content,
    required this.likes,
    required this.likeCount,
    required this.comments,
    required this.timestamp,
    this.location, // Optional, in case location isn’t always provided
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'username': username,
      'title': title,
      'content': content,
      'likes': likes, // Simplified to user IDs
      'likeCount': likeCount,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'timestamp': Timestamp.fromDate(timestamp),
      'location': location, // Add location to Firestore map
    };
  }

  // Create Post object from Firestore data
  factory Post.fromMap(Map<String, dynamic> data, String documentId) {
    return Post(
      postId: documentId,
      userId: data['userId'],
      username: data['username'],
      title: data['title'],
      content: data['content'],
      likes: List<String>.from(data['likes'] ?? []), // Convert to list of strings (user IDs)
      likeCount: data['likeCount'] ?? 0,
      comments: (data['comments'] as List).map((commentData) => Comment.fromMap(commentData)).toList(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      location: data['location'], // Assign location if available
    );
  }

  // Increment like count and add user ID to likes
  Future<void> likePost(String userId) async {
    if (!likes.contains(userId)) {
      final updatedLikes = List<String>.from(likes)..add(userId);
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': updatedLikes,
        'likeCount': likeCount + 1,
      });
    }
  }

  // Decrement like count and remove user ID from likes
  Future<void> unlikePost(String userId) async {
    if (likes.contains(userId)) {
      final updatedLikes = List<String>.from(likes)..remove(userId);
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': updatedLikes,
        'likeCount': likeCount - 1,
      });
    }
  }
}

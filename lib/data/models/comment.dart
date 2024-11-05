// lib/data/models/comment_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'likes.dart';

class Comment {
  final String commentId; // Add commentId field
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;
  final List<Like> likes;
  final List<Comment> replies;
  final Comment? replyTo;

  Comment({
    required this.commentId, // Add commentId to constructor
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.replies,
    this.replyTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId, // Add commentId to map
      'userId': userId,
      'username': username,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes.map((like) => like.toMap()).toList(),
      'replies': replies.map((reply) => reply.toMap()).toList(),
      'replyTo': replyTo?.toMap(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map['commentId'], // Add commentId from map
      userId: map['userId'],
      username: map['username'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      likes: (map['likes'] as List).map((like) => Like.fromMap(like)).toList(),
      replies: (map['replies'] as List).map((reply) => Comment.fromMap(reply)).toList(),
      replyTo: map['replyTo'] != null ? Comment.fromMap(map['replyTo']) : null,
    );
  }
}
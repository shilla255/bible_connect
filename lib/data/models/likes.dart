// lib/data/models/likes.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Like {
  final String userId;
  final String likeId;
  final String username;
  final String postId;
  final DateTime timestamp;

  Like({
    required this.userId,
    required this.likeId,
    required this.username,
    required this.postId,
    required this.timestamp,
  });

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      userId: map['userId'],
      likeId: map['likeId'],
      username: map['username'],
      postId: map['postId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'likeId': likeId,
      'username': username,
      'postId': postId,
      'timestamp': timestamp,
    };
  }
}
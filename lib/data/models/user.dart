import 'package:cloud_firestore/cloud_firestore.dart';

class CustomUser {
  final String uid;
  final String username;
  final String email;
  final List<String> bookmarks; // List of bookmarked post IDs
  final bool isVerified; // Verification status

  CustomUser({
    required this.uid,
    required this.username,
    required this.email,
    this.bookmarks = const [], // Initialize as an empty list
    this.isVerified = false, // Initialize as not verified
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'bookmarks': bookmarks, // Store bookmarks
      'isVerified': isVerified, // Store verification status
    };
  }

  // Create a CustomUser object from Firestore data
  factory CustomUser.fromMap(Map<String, dynamic> data) {
    return CustomUser(
      uid: data['uid'] ?? '', // Ensure non-null uid
      username: data['username'] ?? '', // Ensure non-null username
      email: data['email'] ?? '', // Ensure non-null email
      bookmarks: List<String>.from(data['bookmarks'] ?? []), // Avoid null bookmarks list
      isVerified: data['isVerified'] ?? false, // Ensure non-null verification status
    );
  }

  // Save user data to Firestore
  Future<void> saveToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(uid).set(toMap());
  }

  // Add bookmark
  Future<void> addBookmark(String postId) async {
    final updatedBookmarks = List<String>.from(bookmarks)..add(postId);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bookmarks': updatedBookmarks,
    });
  }

  // Remove bookmark
  Future<void> removeBookmark(String postId) async {
    final updatedBookmarks = List<String>.from(bookmarks)..remove(postId);
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bookmarks': updatedBookmarks,
    });
  }

  // Add copyWith method
  CustomUser copyWith({
    String? uid,
    String? username,
    String? email,
    List<String>? bookmarks,
    bool? isVerified,
  }) {
    return CustomUser(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      bookmarks: bookmarks ?? this.bookmarks,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
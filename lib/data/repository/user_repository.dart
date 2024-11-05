import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as custom;

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addUser(custom.CustomUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<String?> getUsername(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['username'] as String?;
    }
    return null;
  }

  Future<bool?> isEmailVerified(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc['isVerified'] as bool?;
    }
    return null;
  }

  Future<custom.CustomUser?> getUserById(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return custom.CustomUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(custom.CustomUser user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // Bookmark logic
  Future<void> addBookmark(String uid, String bookmarkId) async {
    await _firestore.collection('users').doc(uid).update({
      'bookmarks': FieldValue.arrayUnion([bookmarkId])
    });
  }

  Future<void> removeBookmark(String uid, String bookmarkId) async {
    await _firestore.collection('users').doc(uid).update({
      'bookmarks': FieldValue.arrayRemove([bookmarkId])
    });
  }

  Future<List<String>?> getBookmarks(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return List<String>.from(doc['bookmarks'] as List<dynamic>);
    }
    return null;
  }

  // Add getCurrentUser method
  Future<custom.CustomUser?> getCurrentUser() async {
    // Implement logic to get the current user, e.g., from Firebase Auth
    // For example:
    const uid = 'currentUserId'; // Replace with actual logic to get current user ID
    return getUserById(uid);
  }

  // Add signOut method
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
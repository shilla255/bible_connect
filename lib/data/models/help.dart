import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';

class Help {
  final String id;
  final String userId;
  final String username;
  final String caseTitle;
  final String description;
  final DateTime createdAt;

  Help({
    required this.id,
    required CustomUser user,
    required this.caseTitle,
    required this.description,
    required this.createdAt, required String email, String? priority,
  })  : userId = user.uid,
        username = user.username;

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'caseTitle': caseTitle,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Help object from Firestore data
  factory Help.fromMap(Map<String, dynamic> data) {
    return Help(
      id: data['id'],
      user: CustomUser(
        uid: data['userId'],
        username: data['username'],
        email: '', // Placeholder, as email is not available in Help data
      ),
      caseTitle: data['caseTitle'],
      description: data['description'],
      createdAt: DateTime.parse(data['createdAt']), email: '',
    );
  }

  // Save help request to Firestore
  Future<void> saveToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('helpRequests').doc(id).set(toMap());
  }
}
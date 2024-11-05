import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String reportId;
  final String reporterId;
  final String reportedUserId;
  final String contentId;
  final String contentType;
  final String reason;
  final String description; // Add description field
  final DateTime timestamp;

  Report({
    required this.reportId,
    required this.reporterId,
    required this.reportedUserId,
    required this.contentId,
    required this.contentType,
    required this.reason,
    required this.description, // Initialize description
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'contentId': contentId,
      'contentType': contentType,
      'reason': reason,
      'description': description, // Add description to map
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Report.fromMap(Map<String, dynamic> data, String documentId) {
    return Report(
      reportId: documentId,
      reporterId: data['reporterId'],
      reportedUserId: data['reportedUserId'],
      contentId: data['contentId'],
      contentType: data['contentType'],
      reason: data['reason'],
      description: data['description'], // Fetch description
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
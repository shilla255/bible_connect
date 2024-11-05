// lib/presentation/view/community/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> sendNotification(String token, String title, String body) async {
    await _firebaseMessaging.sendMessage(
      to: token,
      data: {
        'title': title,
        'body': body,
      },
    );
  }
}
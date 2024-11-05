import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String serverKey = 'YOUR_SERVER_KEY'; // Replace with your server key
  final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send'; // Replace with your project ID

  Future<void> sendNotification(String fcmToken, String title, String body) async {
    try {
      var response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {
              'title': title,
              'body': body,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

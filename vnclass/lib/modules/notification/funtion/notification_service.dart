import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'dart:convert';

import 'package:vnclass/modules/notification/funtion/get_access_token.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Biến tĩnh để theo dõi ID thông báo
  static int notificationID = 0;

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/logo');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showNotification(
            message.notification!.title!, message.notification!.body!);
      }
    });
  }

  static Future<void> sendNotification(String accId, List<String> deviceTokens,
      String title, String body) async {
    final String accessToken = await getAccessToken();
    const String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/flutterapp-dde40/messages:send';

    for (String deviceToken in deviceTokens) {
      final Map<String, dynamic> notificationData = {
        'message': {
          'token': deviceToken,
          'notification': {
            'title': title,
            'body': body,
          },
        },
      };

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(notificationData),
      );

      if (response.statusCode != 200) {
        print('Failed to send notification to $deviceToken: ${response.body}');
      } else {
        print('Notification sent to $deviceToken successfully.');
      }
    }
  }

  static Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'Notification', // ID của channel
      'MyChannel', // Tên channel
      channelDescription: 'Description', // Mô tả
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notificationID++, // Tăng ID mỗi khi gửi thông báo
      title, // Tiêu đề
      body, // Nội dung
      platformChannelSpecifics, // Thông tin chi tiết
      payload: 'item x', // Payload nếu cần thiết
    );
  }
}

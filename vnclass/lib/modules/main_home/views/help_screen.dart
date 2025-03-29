import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/classes/view/all_classes.dart';
import 'package:vnclass/modules/conduct/widget/choose_year_dialog.dart';
import 'package:vnclass/modules/notification/model/notification_model.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String? deviceToken;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void getToken() async {
    String? token = await _firebaseMessaging.getToken();
    setState(() {
      deviceToken = token; // Lưu token vào biến
    });
    print("Device Token: $deviceToken");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(80.0),
        child: Column(
          children: [
            Text(
              'Liên hệ hỗ trợ',
              style: TextStyle(fontSize: 20),
            ),
            Text('Gmail:'),
            Text('Discord:'),
          ],
        ),
      ),
    );
  }
}

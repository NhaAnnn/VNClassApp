import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/classes/view/all_classes.dart';
import 'package:vnclass/modules/conduct/widget/choose_year_dialog.dart';
import 'package:vnclass/modules/notification/model/notification_model.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: Column(
        children: [
          BackBar(
            title: 'Trợ giúp',
            leading: false,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liên hệ hỗ trợ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Nếu bạn có bất kỳ câu hỏi nào về ứng dụng VNClass, vui lòng liên hệ với chúng tôi qua các kênh sau:',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final Uri googleDocUri = Uri.parse(
                        'https://docs.google.com/document/d/14UEz1bOal8GK0X7lZBYXLKL6o72xzk1XPrz1QBuF3Ps/edit?usp=sharing');

                    await launchUrl(googleDocUri,
                        mode: LaunchMode.externalApplication);
                  },
                  child: Row(
                    children: [
                      Text(
                        'Hướng dẫn sử dụng: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Xem tại đây',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    final Uri emailLaunchUri = Uri(
                        scheme: 'mailto',
                        path: 'trongnhan2917@gmail.com',
                        query:
                            'subject=Hỗ trợ VNClass&body=Vui lòng nhập nội dung hỗ trợ tại đây.');
                    launchUrl(emailLaunchUri);
                  },
                  child: Row(
                    children: [
                      Text(
                        'Gmail: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'trongnhan2917@gmail.com',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final Uri discordUri =
                        Uri.parse('https://discord.gg/nZY7C5gt');
                    launchUrl(discordUri, mode: LaunchMode.externalApplication);
                  },
                  child: Row(
                    children: [
                      Text(
                        'Discord: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Tham gia tại đây',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Cảm ơn bạn đã sử dụng VNClass <3',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

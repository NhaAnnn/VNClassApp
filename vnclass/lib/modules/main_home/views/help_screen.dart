import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/classes/view/all_classes.dart';
import 'package:vnclass/modules/conduct/widget/choose_year_dialog.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_change.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';
import 'package:vnclass/modules/notification/model/notification_model.dart';
import 'package:vnclass/modules/notification/view/notification_screen.dart';

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
            ButtonWidget(
              title: 'Lớp học',
              ontap: () =>
                  Navigator.of(context).pushNamed(AllClasses.routeName),
            ),
            ButtonWidget(
              title: 'DRL',
              ontap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ChooseYearDialog();
                  },
                );
              },
            ),
            // IconButton(
            //   icon: Stack(
            //     children: [
            //       Icon(
            //         Icons.notifications,
            //         color: Colors.blue,
            //         size: 40,
            //       ),
            //       if (NotificationChange.unreadCount >
            //           0) // Kiểm tra số lượng thông báo chưa đọc
            //         Positioned(
            //           right: 0,
            //           child: Container(
            //             padding: EdgeInsets.all(2),
            //             decoration: BoxDecoration(
            //               color: Colors.red,
            //               borderRadius: BorderRadius.circular(6),
            //             ),
            //             constraints: BoxConstraints(
            //               minWidth: 12,
            //               minHeight: 12,
            //             ),
            //             child: Text(
            //               '${NotificationChange.unreadCount}',
            //               style: TextStyle(
            //                 color: Colors.white,
            //                 fontSize: 10,
            //               ),
            //               textAlign: TextAlign.center,
            //             ),
            //           ),
            //         ),
            //     ],
            //   ),

            //   ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';

import 'package:vnclass/modules/notification/funtion/notification_change.dart';
import 'package:vnclass/modules/notification/model/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static String routeName = 'notification_screen';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  Function? onUpdate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getNotification(); // Ensure context is ready before calling
  }

  Future<void> toggleReadStatus(String id) async {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        if (!notifications[index].isRead) {
          notifications[index].isRead = true;

          Provider.of<NotificationChange>(context, listen: false)
              .decrementUnreadCount();
        }
        onUpdate?.call();
      }
    });
    await NotificationController.setReadNotification(id);
  }

  Future<void> markAllAsRead() async {
    setState(() {
      for (var notification in notifications) {
        if (!notification.isRead) {
          notification.isRead = true;
          Provider.of<NotificationChange>(context, listen: false)
              .decrementUnreadCount();
        }
      }
    });
    await Future.wait(notifications.map((notification) async {
      await NotificationController.setReadNotification(notification.id);
    }));
  }

  void getNotification() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    notifications = args['notifications'] as List<NotificationModel>;

    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    onUpdate = args['onUpdate']; // Receive callback
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue =
        MediaQuery.of(context).size.width * 0.05; // Improved padding
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      body: Column(
        children: [
          BackBar(title: 'Thông báo'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: markAllAsRead,
                child: Row(
                  children: [
                    Text(
                      'Đánh dấu đã đọc tất cả ',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 1, 86, 155),
                          fontSize: 16),
                    ),
                    Icon(
                      Icons.playlist_add_check_rounded,
                      size: 30,
                      color: const Color.fromARGB(255, 0, 90, 164),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Text(
                      'Không có thông báo',
                      style: TextStyle(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 2, 2, 2)),
                    ),
                  )
                : ListView.builder(
                    itemCount: notifications.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        color: const Color.fromARGB(255, 249, 246, 246),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: const Color.fromARGB(115, 104, 104, 104),
                                width: 1) // Rounded corners
                            ),
                        child: ListTile(
                          title: Text(
                            notification.notificationTitle,
                            style: TextStyle(
                              fontSize: 18, // Font size for title
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: notification.isRead
                                  ? Colors.black54
                                  : Colors.black,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, right: 8, bottom: 8),
                            child: Text(
                              notification.notificationDetail,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Colors.black87), // Content text styling
                            ),
                          ),
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              notification.isRead
                                  ? Icons.mark_email_read
                                  : Icons.mark_email_unread,
                              color: notification.isRead
                                  ? Colors.green
                                  : Colors.red,
                              size: 30, // Slightly larger icon
                            ),
                          ),
                          onTap: () => toggleReadStatus(notification.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

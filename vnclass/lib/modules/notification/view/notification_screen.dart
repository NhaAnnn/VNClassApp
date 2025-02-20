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
    getNotification(); // Gọi ở đây để đảm bảo context đã sẵn sàng
  }

  Future<void> toggleReadStatus(String id) async {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        if (!notifications[index].isRead) {
          // Chỉ thay đổi trạng thái nếu nó chưa đọc
          notifications[index].isRead = true; // Đánh dấu là đã đọc

          // Cập nhật số lượng thông báo chưa đọc
          Provider.of<NotificationChange>(context, listen: false)
              .decrementUnreadCount();
        }
        onUpdate?.call(); // Gọi callback để thông báo sự thay đổi
      }
    });
    await NotificationController.setReadNotification(id);
  }

  void getNotification() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    notifications = args['notifications'] as List<NotificationModel>;

    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    onUpdate = args['onUpdate']; // Nhận callback
  }

  @override
  Widget build(BuildContext context) {
    double paddingValue = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      body: Column(
        children: [
          BackBar(title: 'Thông báo'),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Text(
                      'Không có thông báo',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(paddingValue * 0.02),
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Card(
                          elevation: 8,
                          margin: EdgeInsets.symmetric(
                              vertical: paddingValue * 0.001),
                          child: ListTile(
                            shape: Border.symmetric(
                                horizontal: BorderSide(color: Colors.grey)),
                            title: Text(
                              notification.notificationTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: notification.isRead
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              notification.notificationDetail,
                              style: TextStyle(fontSize: 16),
                            ),
                            tileColor: notification.isRead
                                ? Colors.grey[300]
                                : Colors.white,
                            leading: Icon(
                              notification.isRead
                                  ? Icons.mark_email_read
                                  : Icons.mark_email_unread,
                              color: notification.isRead
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            onTap: () => toggleReadStatus(notification.id),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

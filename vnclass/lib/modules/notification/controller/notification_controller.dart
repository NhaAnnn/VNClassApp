import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/notification/model/notification_model.dart';

class NotificationController {
  static Future<List<NotificationModel>> fetchNotifications(
      String accountId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('NOTIFICATION')
          .where('ACC_id', isEqualTo: accountId)
          .get();
      return snapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Lỗi khi lấy dữ liệu: $e');
      return [];
    }
  }

  static Future<void> createNotification(
      String accId, String notificationTitle, String notificationDetail) async {
    try {
      final FirebaseFirestore db = FirebaseFirestore.instance;
      // Tạo id mới
      String newId = (accId + DateTime.now().toString()).toString();

      // Tạo đối tượng DeviceModel mới
      NotificationModel newNotification = NotificationModel(
          accountId: accId,
          id: newId,
          notificationTitle: notificationTitle,
          notificationDetail: notificationDetail,
          isRead: false,
          timestamp: DateTime.now());

      // Lưu vào Firestore
      await db
          .collection('NOTIFICATION')
          .doc(newId)
          .set(newNotification.toMap());
      print('Dữ liệu NOTIFICATION đã được thêm thành công.');
    } catch (e) {
      print('Lỗi khi thêm dữ liệu NOTIFICATION: $e');
    }
  }

  static Future<void> setReadNotification(String id) async {
    try {
      final Map<String, dynamic> updateData = {
        '_isRead': true,
      };
      // Lưu vào Firestore
      FirebaseFirestore.instance
          .collection('NOTIFICATION')
          .doc(id)
          .update(updateData);
      print('NOTIFICATION đã được đọc thành công.');
    } catch (e) {
      print('Lỗi khi thêm dữ liệu NOTIFICATION: $e');
    }
  }
}

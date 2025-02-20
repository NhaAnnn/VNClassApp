import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String accountId;
  final String id;
  final String notificationTitle;
  final String notificationDetail;
  bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.accountId,
    required this.id,
    required this.notificationTitle,
    required this.notificationDetail,
    required this.isRead,
    required this.timestamp,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null");
    }

    return NotificationModel(
      id: data['_id'],
      accountId: data['ACC_id'],
      notificationTitle: data['_notificationTitle'],
      notificationDetail: data['_notificationDetail'],
      isRead: data['_isRead'],
      timestamp: (data['_time'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ACC_id': accountId,
      '_id': id,
      '_notificationTitle': notificationTitle,
      '_notificationDetail': notificationDetail,
      '_isRead': isRead,
      '_time': timestamp,
    };
  }
}

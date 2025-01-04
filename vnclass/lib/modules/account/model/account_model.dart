import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String accName;
  final String accPass;
  final String className;

  AccountModel({
    required this.className,
    required this.accPass,
    required this.accName,
  });

  // Tạo từ tài liệu Firestore
  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return AccountModel(
      className: data['name'] ?? '',
      accName: data['semester'] ?? '',
      accPass: data['academicYear'] ?? '',
    );
  }
}

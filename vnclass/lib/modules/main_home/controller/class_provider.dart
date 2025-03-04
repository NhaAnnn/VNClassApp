import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClassProvider with ChangeNotifier {
  final FirebaseFirestore firestore;
  List<String> classNames = []; // Danh sách tên các lớp học

  ClassProvider({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> fetchClassNames() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('CLASS').get();
      classNames = snapshot.docs
          .map((doc) => (doc.get('_className') as String)
              .toUpperCase()) // Chuyển thành chữ in hoa
          .toList();
      print('Danh sách lớp học đã được tải: $classNames');
      notifyListeners(); // Thông báo khi dữ liệu thay đổi
    } catch (e) {
      print('Lỗi khi tải danh sách lớp học: $e');
    }
  }
}

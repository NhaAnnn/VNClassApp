import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class YearProvider with ChangeNotifier {
  final FirebaseFirestore firestore;
  List<String> years = []; // Danh sách năm học

  YearProvider({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> fetchYears() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('YEAR').get();
      years =
          snapshot.docs.map((doc) => doc.id).toList(); // Lưu các ID của năm học
      print('Năm học đã được tải: $years'); // In ra danh sách năm học
      notifyListeners(); // Thông báo cho các listener rằng dữ liệu đã thay đổi
    } catch (e) {
      print('Lỗi khi tải năm học: $e'); // In ra lỗi nếu có
    }
  }
}

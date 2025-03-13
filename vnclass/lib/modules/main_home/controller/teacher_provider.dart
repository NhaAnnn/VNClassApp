import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherProvider with ChangeNotifier {
  final FirebaseFirestore firestore;

  String classIdTeacher = '';

  TeacherProvider({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> fetchClassIDTeacher(String accId) async {
    try {
      // Lấy thông tin sinh viên từ collection STUDENT
      print('Tìm kiếm teach với accId: $accId');
      QuerySnapshot classSnapshot = await firestore
          .collection('CLASS')
          .where('T_id', isEqualTo: accId)
          .get();

      // Kiểm tra nếu có tài liệu nào được tìm thấy
      if (classSnapshot.docs.isEmpty) {
        throw Exception('Không tìm thấy sinh viên với accId: $accId');
      }

      DocumentSnapshot classDoc = classSnapshot.docs.first;

      // Ép kiểu dữ liệu trả về từ data() thành Map<String, dynamic>
      Map<String, dynamic>? classData =
          classDoc.data() as Map<String, dynamic>?;

      // Kiểm tra xem trường _id có tồn tại không
      if (classData == null || !classData.containsKey('_id')) {
        throw Exception('Trường _id không tồn tại trong tài liệu.');
      }

      classIdTeacher = classData['_id'] ?? '';

      print('Giá trị của _id: $classIdTeacher');

      //

      // Thông báo cho các listener rằng dữ liệu đã thay đổi
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải thông tin chi tiết sinh viên: $e');
      // Xử lý lỗi nếu cần
    }
  }
}

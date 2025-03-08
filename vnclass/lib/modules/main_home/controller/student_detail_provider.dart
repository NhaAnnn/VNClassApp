import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';

class StudentDetailProvider with ChangeNotifier {
  final FirebaseFirestore firestore;
  StudentDetailModel?
      studentDetail; // Biến lưu trữ thông tin chi tiết sinh viên
  String classIdST = '';

  StudentDetailProvider({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> fetchStudentDetail(String accId) async {
    try {
      // Lấy thông tin sinh viên từ collection STUDENT
      print('Tìm kiếm sinh viên với accId: $accId');
      QuerySnapshot studentSnapshot = await firestore
          .collection('STUDENT')
          .where('ACC_id', isEqualTo: accId)
          .get();

      // Kiểm tra nếu có tài liệu nào được tìm thấy
      if (studentSnapshot.docs.isEmpty) {
        throw Exception('Không tìm thấy sinh viên với accId: $accId');
      }

      DocumentSnapshot studentDoc = studentSnapshot.docs.first;

      // Ép kiểu dữ liệu trả về từ data() thành Map<String, dynamic>
      Map<String, dynamic>? studentData =
          studentDoc.data() as Map<String, dynamic>?;

      // Kiểm tra xem trường _id có tồn tại không
      if (studentData == null || !studentData.containsKey('_id')) {
        throw Exception('Trường _id không tồn tại trong tài liệu.');
      }

      String idStudent = studentData['_id'] ?? '';
      String stId = studentData['ST_id'] ?? ''; // Lấy ST_id nếu cần
      print('Giá trị của _id: $idStudent');

      // Lấy thông tin chi tiết sinh viên từ collection STUDENT_DETAIL
      QuerySnapshot detailSnapshot = await firestore
          .collection('STUDENT_DETAIL')
          .where('ST_id', isEqualTo: idStudent)
          .get();

      // Kiểm tra nếu có tài liệu nào được tìm thấy
      if (detailSnapshot.docs.isEmpty) {
        throw Exception(
            'Không tìm thấy chi tiết sinh viên với ST_id: $idStudent');
      }

      DocumentSnapshot detailDoc = detailSnapshot.docs.first;
      classIdST =
          detailDoc['Class_id'] ?? ''; // Lấy Class_id từ tài liệu chi tiết
      print('Mã lớp của học sinh: $classIdST');

      // // Tạo đối tượng StudentDetailModel từ tài liệu Firestore
      // studentDetail = await StudentDetailModel.fromFirestore(detailDoc);

      // Thông báo cho các listener rằng dữ liệu đã thay đổi
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải thông tin chi tiết sinh viên: $e');
      // Xử lý lỗi nếu cần
    }
  }
}

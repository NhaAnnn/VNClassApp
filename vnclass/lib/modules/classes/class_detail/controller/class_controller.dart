import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';

class ClassController {
  static Future<List<ClassModel>> fetchAllClasses() async {
    try {
      final QuerySnapshot =
          await FirebaseFirestore.instance.collection('CLASS').get();

      List<ClassModel> classes = []; // Khởi tạo danh sách học sinh

      for (var doc in QuerySnapshot.docs) {
        // Lặp qua từng tài liệu
        ClassModel classInfo = await ClassModel.fetchCLassFromFirestore(
            doc); // Gọi hàm lấy thông tin học sinh
        classes.add(classInfo); // Thêm học sinh vào danh sách
      }

      return classes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch mistake types: $e');
      return []; // Trả về danh sách rỗng trong trường hợp có lỗi
    }
  }

  static Future<List<ClassModel>> fetchAllClassesByYear(String year) async {
    try {
      final QuerySnapshot = await FirebaseFirestore.instance
          .collection('CLASS')
          .where('_year', isEqualTo: year)
          .get();

      List<ClassModel> classes = []; // Khởi tạo danh sách học sinh

      for (var doc in QuerySnapshot.docs) {
        // Lặp qua từng tài liệu
        ClassModel classInfo = await ClassModel.fetchCLassFromFirestore(
            doc); // Gọi hàm lấy thông tin học sinh
        classes.add(classInfo); // Thêm học sinh vào danh sách
      }

      return classes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch mistake types: $e');
      return []; // Trả về danh sách rỗng trong trường hợp có lỗi
    }
  }

  static Future<bool> classExists(String classId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('CLASS')
        .where('_id', isEqualTo: classId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  static Future<void> createClass(BuildContext context, String className,
      String teacherId, String teacherName, String year) async {
    // Tạo dữ liệu mới
    final Map<String, dynamic> newData = {
      'T_id': teacherId,
      'T_name': teacherName,
      '_amount': 0,
      '_className': className,
      '_numberOfMisAll': '',
      '_numberOfMisS1': '',
      '_numberOfMisS2': '',
      '_year': year
    };

    // Tạo document ID từ className và year
    String documentId = className.replaceAll(' ', '').toLowerCase() + year;
    print('Unique ID: $documentId');

    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('YEAR').doc(year).get();

      if (!doc.exists) {
        print("Tạo năm học $year.");
        final Map<String, dynamic> newYear = {'_year': year};
        await FirebaseFirestore.instance
            .collection('YEAR')
            .doc(year)
            .set(newYear);
      }
      // Gán document ID vào dữ liệu mới
      newData['_id'] = documentId; // Gán document ID

      // Thêm tài liệu mới vào collection với document ID đã chỉ định
      await FirebaseFirestore.instance
          .collection('CLASS')
          .doc(documentId) // Sử dụng document ID
          .set(newData);

      print("Dữ liệu đã được tạo thành công.");
    } catch (e) {
      print("Lỗi khi tạo dữ liệu: $e");
    }
  }

  static Future<void> deleteClass(String classId) async {
    try {
      await FirebaseFirestore.instance
          .collection('CLASS')
          .doc(classId) // Sử dụng document ID
          .delete();

      print("Dữ liệu đã  xóa thành công.");
    } catch (e) {
      print("Lỗi khi tạo dữ liệu: $e");
    }
  }

  static Future<void> updateTeacherName(
      String classId, String teacherId, String teacherName) async {
    // Tạo dữ liệu cập nhật chỉ bao gồm tên giáo viên
    final Map<String, dynamic> updateData = {
      'T_id': teacherId,
      'T_name': teacherName,
    };

    try {
      await FirebaseFirestore.instance
          .collection('CLASS')
          .doc(classId) // Sử dụng document ID
          .update(updateData);

      print("Tên giáo viên đã được cập nhật thành công.");
    } catch (e) {
      print("Lỗi khi cập nhật tên giáo viên: $e");
    }
  }
}

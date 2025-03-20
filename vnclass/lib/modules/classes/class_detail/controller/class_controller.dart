import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';

class ClassController {
  static Future<List<ClassModel>> fetchAllClasses() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('CLASS').get();

      // Tạo danh sách các Future để thực hiện song song
      List<Future<ClassModel>> classFutures =
          querySnapshot.docs.map((doc) async {
        return await ClassModel.fetchClassFromFirestore(doc);
      }).toList();

      // Chạy tất cả các Future song song và đợi cho đến khi tất cả hoàn thành
      List<ClassModel> classes = await Future.wait(classFutures);

      return classes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch classes: $e');
      return []; // Trả về danh sách rỗng trong trường hợp có lỗi
    }
  }

  static Future<List<ClassModel>> fetchAllClassesByYear(String year) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('CLASS')
          .where('_year', isEqualTo: year)
          .get();

      // Tạo danh sách các Future để thực hiện song song
      List<Future<ClassModel>> classFutures =
          querySnapshot.docs.map((doc) async {
        return await ClassModel.fetchClassFromFirestore(doc);
      }).toList();

      // Chạy tất cả các Future song song và đợi cho đến khi tất cả hoàn thành
      List<ClassModel> classes = await Future.wait(classFutures);

      return classes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch classes: $e');
      return []; // Trả về danh sách rỗng trong trường hợp có lỗi
    }
  }

  static Future<List<ClassModel>> fetchAllClassesByTearcherID(
      String teacherId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('CLASS')
          .where('T_id', isEqualTo: teacherId)
          .get();

      // Tạo danh sách các Future để thực hiện song song
      List<Future<ClassModel>> classFutures =
          querySnapshot.docs.map((doc) async {
        return await ClassModel.fetchClassFromFirestore(doc);
      }).toList();

      // Chạy tất cả các Future song song và đợi cho đến khi tất cả hoàn thành
      List<ClassModel> classes = await Future.wait(classFutures);

      return classes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch classes: $e');
      return []; // Trả về danh sách rỗng trong trường hợp có lỗi
    }
  }

  static Future<List<ClassModel>> fetchAllClassesByYearAndTearcher(
      String year, String teacherId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('CLASS')
          .where('_year', isEqualTo: year)
          .where('T_id', isEqualTo: teacherId)
          .get();

      // Tạo danh sách các Future để thực hiện song song
      List<Future<ClassModel>> classFutures =
          querySnapshot.docs.map((doc) async {
        return await ClassModel.fetchClassFromFirestore(doc);
      }).toList();

      // Chạy tất cả các Future song song và đợi cho đến khi tất cả hoàn thành
      List<ClassModel> classes = await Future.wait(classFutures);

      return classes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch classes: $e');
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
    final newId = <String, dynamic>{'_id': documentId};
    newData.addEntries(newId.entries);

    try {
      // Tạo một Future để kiểm tra năm học
      Future<void> checkYearFuture = Future(() async {
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
      });

      // Thực hiện kiểm tra năm học và thêm lớp song song
      await Future.wait([
        checkYearFuture,
        FirebaseFirestore.instance
            .collection('CLASS')
            .doc(documentId) // Sử dụng document ID
            .set(newData),
      ]);

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

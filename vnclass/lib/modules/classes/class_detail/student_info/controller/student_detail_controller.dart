import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/controller/conduct_month_controller.dart';

class StudentDetailController {
  // Phương thức để lấy tất cả học sinh
  static Future<List<StudentDetailModel>> fetchAllStudents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL') // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      List<StudentDetailModel> listStu = []; // Khởi tạo danh sách học sinh

      for (var doc in querySnapshot.docs) {
        // Lặp qua từng tài liệu
        StudentDetailModel student =
            await StudentDetailModel.fetchFromFirestore(
                doc); // Gọi hàm lấy thông tin học sinh
        listStu.add(student); // Thêm học sinh vào danh sách
      }

      return listStu; // Trả về danh sách học sinh
    } catch (e) {
      print("Error fetching students: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  static Future<List<StudentDetailModel>> fetchStudentsByClass(
      String classID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('Class_id', isEqualTo: classID) // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      List<StudentDetailModel> listStu = []; // Khởi tạo danh sách học sinh

      for (var doc in querySnapshot.docs) {
        // Lặp qua từng tài liệu
        StudentDetailModel student =
            await StudentDetailModel.fetchFromFirestore(
                doc); // Gọi hàm lấy thông tin học sinh
        listStu.add(student); // Thêm học sinh vào danh sách
      }

      return listStu; // Trả về danh sách học sinh
    } catch (e) {
      print("Error fetching students: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  static Future<List<StudentDetailModel>> fetchStudentsByStudentId(
      String stuID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('ST_id', isEqualTo: stuID) // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      List<StudentDetailModel> listStu = []; // Khởi tạo danh sách học sinh

      for (var doc in querySnapshot.docs) {
        // Lặp qua từng tài liệu
        StudentDetailModel student =
            await StudentDetailModel.fetchFromFirestore(
                doc); // Gọi hàm lấy thông tin học sinh
        listStu.add(student); // Thêm học sinh vào danh sách
      }

      return listStu; // Trả về danh sách học sinh
    } catch (e) {
      print("Error fetching students: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  static Future<StudentDetailModel> fetchStudentDetailByID(
      String studentID) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL') // Tên bộ sưu tập
          .doc(studentID) // ID tài liệu
          .get(); // Lấy tài liệu

      // Chuyển đổi DocumentSnapshot thành StudentInfoModel
      if (snapshot.exists) {
        return StudentDetailModel.fetchFromFirestore(snapshot);
      } else {
        return StudentDetailModel(); // Hoặc một giá trị mặc định nếu không tìm thấy
      }
    } catch (e) {
      print("Error fetching student info: $e");
      return StudentDetailModel(); // Trả về giá trị mặc định nếu có lỗi
    }
  }

  static void updateStudentPositionInDatabase(
      BuildContext context, StudentDetailModel StudentDetailModel) {
    FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .doc(StudentDetailModel.id)
        .update({
      '_committee': StudentDetailModel.committee,
    }).then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Cập nhật chức vụ thành công'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Thông báo'),
            content: Text('Cập nhật chức vụ thất bại: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  static Future<int> fetchStudentsConductTerm1ByClass(
      String classID, String conduct) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('Class_id', isEqualTo: classID)
          .where('_conductTerm1', isEqualTo: conduct) // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      return querySnapshot.size;
    } catch (e) {
      print("Error fetching students: $e");
      return 0;
    }
  }

  static Future<int> fetchStudentsConductTerm2ByClass(
      String classID, String conduct) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('Class_id', isEqualTo: classID)
          .where('_conductTerm2', isEqualTo: conduct) // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      return querySnapshot.size;
    } catch (e) {
      print("Error fetching students: $e");
      return 0;
    }
  }

  static Future<int> fetchStudentsConductAllTermByClass(
      String classID, String conduct) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('Class_id', isEqualTo: classID)
          .where('_conductAllYear', isEqualTo: conduct) // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      return querySnapshot.size;
    } catch (e) {
      print("Error fetching students: $e");
      return 0;
    }
  }

  static Future<int> fetchStudentsConductMonthByClass(
      String classID, String month, String conduct) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('Class_id', isEqualTo: classID)
          .get();

      // Lấy danh sách ID học sinh
      List<String> studentIds =
          querySnapshot.docs.map((doc) => doc.id).toList();

      // Tạo danh sách các Future để thực hiện song song
      List<Future<bool>> conductFutures = studentIds.map((studentId) async {
        String conductStudent =
            await ConductMonthController.fetchConductMonthByOneMonth(
                studentId, month, 1);
        return conductStudent == conduct;
      }).toList();

      // Chạy tất cả các Future song song và đợi cho đến khi tất cả hoàn thành
      List<bool> results = await Future.wait(conductFutures);

      // Đếm số học sinh có hành kiểm tốt
      int conductCount = results.where((result) => result).length;

      return conductCount; // Trả về số học sinh có hành kiểm tốt
    } catch (e) {
      print("Error fetching students: $e");
      return 0; // Trả về 0 nếu có lỗi
    }
  }

  static Future<String> fetchConductAllYearByID(String studentID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('_id', isEqualTo: studentID)
          .get();

      String conductAllYear = '';
      for (var doc in querySnapshot.docs) {
        conductAllYear = doc['_conductAllYear'] ?? '';
      }
      return conductAllYear;
    } catch (e) {
      print("Error fetching conduct all year: $e");
      return '';
    }
  }

  // Lấy dữ liệu hạnh kiểm học kỳ 1
  static Future<String> fetchConductTerm1ByID(String studentID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('_id', isEqualTo: studentID)
          .get();

      for (var doc in querySnapshot.docs) {
        return doc['_conductTerm1'] ?? '';
      }

      return 'conductTerm1';
    } catch (e) {
      print("Error fetching conduct term 1: $e");
      return '';
    }
  }

  // Lấy dữ liệu hạnh kiểm học kỳ 2
  static Future<String> fetchConductTerm2ByID(String studentID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('_id', isEqualTo: studentID)
          .get();

      String conductTerm2 = '';
      for (var doc in querySnapshot.docs) {
        conductTerm2 = doc['_conductTerm2'] ?? '';
      }
      return conductTerm2;
    } catch (e) {
      print("Error fetching conduct term 2: $e");
      return '';
    }
  }
}

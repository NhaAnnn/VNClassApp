import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';

class StudentController {
  // Hàm lấy thông tin học sinh từ Firestore
  static Future<StudentModel> fetchStudentInfoByID(String studentID) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('STUDENT') // Tên bộ sưu tập
          .doc(studentID) // ID tài liệu
          .get(); // Lấy tài liệu

      // Chuyển đổi DocumentSnapshot thành StudentInfoModel
      if (snapshot.exists) {
        return StudentModel.fromFirestore(snapshot);
      } else {
        return StudentModel();
      }
    } catch (e) {
      print("Error fetching student info: $e");
      return StudentModel();
    }
  }

  static Future<List<StudentModel>> fetchStudentInfoByParentID(
      String parentID) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('STUDENT') // Tên bộ sưu tập
              .where('P_id', isEqualTo: parentID) // ID tài liệu
              .get(); // Lấy tài liệu

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((e) => StudentModel.fromFirestore(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching student info: $e");
      return [];
    }
  }

  static Future<String> fetchAccountByID(String studentID) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('STUDENT') // Tên bộ sưu tập
          .doc(studentID) // ID tài liệu
          .get(); // Lấy tài liệu

      if (snapshot.exists) {
        return snapshot.get('ACC_id').toString();
      } else {
        return '';
      }
    } catch (e) {
      print("Error fetching student info: $e");
      return ''; // Trả về giá trị mặc định nếu có lỗi
    }
  }
}

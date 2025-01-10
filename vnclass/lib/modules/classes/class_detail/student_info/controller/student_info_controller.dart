import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_info_model.dart';

class StudentInfoController {
  // Hàm lấy thông tin học sinh từ Firestore
  static Future<StudentInfoModel> fetchStudentInfoByID(String studentID) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('STUDENT') // Tên bộ sưu tập
          .doc(studentID) // ID tài liệu
          .get(); // Lấy tài liệu

      // Chuyển đổi DocumentSnapshot thành StudentInfoModel
      if (snapshot.exists) {
        return StudentInfoModel.fromFirestore(snapshot);
      } else {
        return StudentInfoModel(); // Hoặc một giá trị mặc định nếu không tìm thấy
      }
    } catch (e) {
      print("Error fetching student info: $e");
      return StudentInfoModel(); // Trả về giá trị mặc định nếu có lỗi
    }
  }
}

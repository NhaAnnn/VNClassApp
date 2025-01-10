import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';

class StudentController {
  // Phương thức để lấy tất cả học sinh
  static Future<List<StudentModel>> fetchAllStudents() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL') // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      List<StudentModel> listStu = []; // Khởi tạo danh sách học sinh

      for (var doc in querySnapshot.docs) {
        // Lặp qua từng tài liệu
        StudentModel student = await StudentModel.fetchFromFirestore(
            doc); // Gọi hàm lấy thông tin học sinh
        listStu.add(student); // Thêm học sinh vào danh sách
      }

      return listStu; // Trả về danh sách học sinh
    } catch (e) {
      print("Error fetching students: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  static Future<List<StudentModel>> fetchStudentsByClass(String classID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .where('Class_id', isEqualTo: classID) // Tên bộ sưu tập
          .get(); // Lấy tất cả tài liệu

      List<StudentModel> listStu = []; // Khởi tạo danh sách học sinh

      for (var doc in querySnapshot.docs) {
        // Lặp qua từng tài liệu
        StudentModel student = await StudentModel.fetchFromFirestore(
            doc); // Gọi hàm lấy thông tin học sinh
        listStu.add(student); // Thêm học sinh vào danh sách
      }

      return listStu; // Trả về danh sách học sinh
    } catch (e) {
      print("Error fetching students: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  static void updateStudentPositionInDatabase(StudentModel studentModel) {
    FirebaseFirestore.instance
        .collection('STUDENT_DETAIL')
        .doc(studentModel.id)
        .update({
      '_committee': studentModel.committee,
    }).then((_) {
      print('Cập nhật chức vụ thành công');
    }).catchError((error) {
      print('Cập nhật chức vụ thất bại: $error');
    });
  }
}

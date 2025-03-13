import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/mistake/models/student_mistake_model.dart';

class StudentDetailModel {
  final String idStudent;
  final StudentMistakeModel student;
  final String nameStudent;
  final String numberOfErrors;
  final String committee;
  final String conductAllYear;
  final String id;
  final String classID;

  StudentDetailModel({
    required this.idStudent,
    required this.nameStudent,
    required this.numberOfErrors,
    required this.classID,
    required this.committee,
    required this.conductAllYear,
    required this.student,
    required this.id,
  });

  // Factory constructor cũ (giữ nguyên logic)
  static Future<StudentDetailModel> fromFirestore(
      DocumentSnapshot doc, String month) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Lấy idStudent từ tài liệu hiện tại
    String idStudent = data['ST_id'] ?? '';
    String id = data['_id'] ?? '';

    // Lấy thông tin sinh viên từ collection STUDENT
    QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
        .collection('STUDENT')
        .where('_id', isEqualTo: idStudent)
        .get();

    // Kiểm tra nếu có tài liệu nào được tìm thấy
    if (studentSnapshot.docs.isEmpty) {
      throw Exception('Không tìm thấy sinh viên với id: $idStudent');
    }

    DocumentSnapshot studentDoc = studentSnapshot.docs.first;
    StudentMistakeModel student = StudentMistakeModel.fromFirestore(studentDoc);

    // Đếm số lượng tài liệu trong MISTAKE_MONTH theo tháng
    QuerySnapshot mistakeSnapshot = await FirebaseFirestore.instance
        .collection('MISTAKE_MONTH')
        .where('STD_id', isEqualTo: id)
        .where('_month', isEqualTo: 'Tháng $month')
        .get();

    String numberOfErrors = mistakeSnapshot.docs.length.toString();

    return StudentDetailModel(
      idStudent: idStudent,
      nameStudent: student.nameStudent,
      numberOfErrors: numberOfErrors,
      classID: data['Class_id'] ?? '',
      committee: data['_committee'] ?? '',
      conductAllYear: data['_conductAllYear'] ?? '',
      student: student,
      id: id,
    );
  }

  // Phương thức mới để đếm tổng tất cả lỗi (bỏ qua lỗi)
  static Future<StudentDetailModel?> fromFirestoreTotalErrors(
      DocumentSnapshot doc) async {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Lấy idStudent từ tài liệu hiện tại
      String idStudent = data['ST_id'] ?? '';
      String id = data['_id'] ?? '';

      // Lấy thông tin sinh viên từ collection STUDENT
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('STUDENT')
          .where('_id', isEqualTo: idStudent)
          .get();

      if (studentSnapshot.docs.isEmpty) {
        print('Không tìm thấy sinh viên với id: $idStudent, bỏ qua...');
        return null; // Bỏ qua nếu không tìm thấy
      }

      DocumentSnapshot studentDoc = studentSnapshot.docs.first;
      StudentMistakeModel student =
          StudentMistakeModel.fromFirestore(studentDoc);

      // Đếm tổng số lỗi từ MISTAKE_MONTH (không lọc theo tháng)
      QuerySnapshot mistakeSnapshot = await FirebaseFirestore.instance
          .collection('MISTAKE_MONTH')
          .where('STD_id', isEqualTo: id)
          .get();

      String numberOfErrors = mistakeSnapshot.docs.length.toString();

      return StudentDetailModel(
        idStudent: idStudent,
        nameStudent: student.nameStudent,
        numberOfErrors: numberOfErrors,
        classID: data['Class_id'] ?? '',
        committee: data['_committee'] ?? '',
        conductAllYear: data['_conductAllYear'] ?? '',
        student: student,
        id: id,
      );
    } catch (e) {
      print('Lỗi khi xử lý tài liệu ${doc.id}: $e, bỏ qua...');
      return null; // Bỏ qua nếu có lỗi
    }
  }

  @override
  String toString() {
    return 'StudentDetailModel(idStudent: $idStudent, nameStudent: $nameStudent, numberOfErrors: $numberOfErrors, classID: $classID, committee: $committee, conductAllYear: $conductAllYear, student: ${student.toString()}, id: $id)';
  }
}

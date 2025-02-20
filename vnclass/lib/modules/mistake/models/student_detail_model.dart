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

  // Factory constructor không thể async, nên tách logic ra một phương thức riêng
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

    // Đếm số lượng tài liệu trong MISTAKE_MONTH
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

  @override
  String toString() {
    return 'StudentDetailModel(idStudent: $idStudent, nameStudent: $nameStudent, numberOfErrors: $numberOfErrors, classID: $classID, committee: $committee, conductAllYear: $conductAllYear, student: ${student.toString()}, id: $id)';
  }
}

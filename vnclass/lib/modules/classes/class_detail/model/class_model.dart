import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';

class ClassModel {
  String? id;
  String? className;
  int? amount;
  String? year;
  String? teacherID;
  String? teacherName;
  List<StudentModel>? studentModel;

  ClassModel({
    this.id,
    this.className,
    this.amount,
    this.year,
    this.teacherID,
    this.teacherName,
    required List<StudentModel> studentModel,
  });
  // Hàm lấy thông tin học sinh từ Firestore
  static Future<ClassModel> fetchCLassFromFirestore(
      DocumentSnapshot doc) async {
    // Lấy dữ liệu từ tài liệu
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null");
    }

    String classID = data['Class_id'] ?? '';

    // Lấy thông tin học sinh
    List<StudentModel> studentModel =
        await StudentController.fetchStudentsByClass(classID);

    // Tạo một đối tượng StudentModel
    return ClassModel(
      id: data['_id'],
      className: data['_className'] ?? '',
      year: data['_year'] ?? '',
      amount: data['_amount'] ?? 0,
      teacherID: data['T_id'] ?? '',
      teacherName: data['T_name'] ?? '',
      studentModel: studentModel,
    );
  }
}

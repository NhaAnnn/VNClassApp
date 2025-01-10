import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_info_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_info_model.dart';

class StudentModel {
  String? id;
  String? classID;
  String? studentID;
  String? conductTerm1;
  String? conductTerm2;
  String? conductAllYear;
  String? committee;
  StudentInfoModel studentInfoModel;

  StudentModel({
    this.id,
    this.classID,
    this.studentID,
    required this.studentInfoModel,
    this.conductTerm1,
    this.conductTerm2,
    this.conductAllYear,
    this.committee,
  });

  // Hàm lấy thông tin học sinh từ Firestore
  static Future<StudentModel> fetchFromFirestore(DocumentSnapshot doc) async {
    // Lấy dữ liệu từ tài liệu
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null");
    }

    String stuID = data['ST_id'] ?? '';

    // Lấy thông tin học sinh
    StudentInfoModel studentInfoModel =
        await StudentInfoController.fetchStudentInfoByID(stuID);

    // Tạo một đối tượng StudentModel
    return StudentModel(
      id: data['_id'] ?? '',
      classID: data['Class_id'] ?? '',
      studentID: stuID,
      conductTerm1: data['_conductTerm1'] ?? '',
      conductTerm2: data['_conductTerm2'] ?? '',
      conductAllYear: data['_conductAllYear'] ?? '',
      committee: data['_committee'] ?? '',
      studentInfoModel: studentInfoModel,
    );
  }
}

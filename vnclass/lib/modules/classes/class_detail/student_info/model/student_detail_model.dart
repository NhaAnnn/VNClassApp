import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailModel {
  String? id;
  String? classID;
  String? className;
  String? studentID;
  String? studentName;
  String? birthday;
  String? gender;
  String? phone;
  String? conductTerm1;
  String? conductTerm2;
  String? conductAllYear;
  String? committee;
  // StudentInfoModel studentInfoModel;
  // ConductMonthModel? conductMonthModel;

  StudentDetailModel({
    this.id,
    this.classID,
    this.className,
    this.studentID,
    this.studentName,
    this.birthday,
    this.gender,
    this.phone,
    // required this.studentInfoModel,
    this.conductTerm1,
    this.conductTerm2,
    this.conductAllYear,
    this.committee,
    // this.conductMonthModel,
  });

  // Hàm lấy thông tin học sinh từ Firestore
  static Future<StudentDetailModel> fetchFromFirestore(
      DocumentSnapshot doc) async {
    // Lấy dữ liệu từ tài liệu
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null");
    }

    String stuID = data['ST_id'] ?? '';

    // Lấy thông tin học sinh
    // StudentInfoModel studentInfoModel =
    //     await StudentInfoController.fetchStudentInfoByID(stuID);
    // ConductMonthModel conductMonthModel =
    //     await ConductMonthController.fetchConductMonth(stuID);

    // Tạo một đối tượng StudentModel
    return StudentDetailModel(
      id: data['_id'] ?? '',
      classID: data['Class_id'] ?? '',
      className: data['Class_name'] ?? '',
      studentID: stuID,
      studentName: data['_studentName'] ?? '',
      birthday: data['_birthday'] ?? '',
      gender: data['_gender'] ?? '',
      phone: data['_phone'] ?? '',
      conductTerm1: data['_conductTerm1'] ?? '',
      conductTerm2: data['_conductTerm2'] ?? '',
      conductAllYear: data['_conductAllYear'] ?? '',
      committee: data['_committee'] ?? '',
      // studentInfoModel: studentInfoModel,
      // conductMonthModel: conductMonthModel,
    );
  }
}

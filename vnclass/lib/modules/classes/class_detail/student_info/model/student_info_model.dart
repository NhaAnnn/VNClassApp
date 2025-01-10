import 'package:cloud_firestore/cloud_firestore.dart';

class StudentInfoModel {
  String? id;
  String? studentName;
  String? birthday;
  String? gender;
  String? phone;
  String? accountID;

  StudentInfoModel({
    this.id,
    this.studentName,
    this.birthday,
    this.gender,
    this.phone,
    this.accountID,
  });

  factory StudentInfoModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return StudentInfoModel(
      id: data['_id'] ?? '',
      studentName: data['_studentName'] ?? '',
      birthday: data['_birthday'] ?? '',
      gender: data['_gender'] ?? '',
      phone: data['_phone'] ?? '',
      accountID: data['ACC_id'] ?? '',
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  String? id;
  String? studentName;
  String? birthday;
  String? gender;
  String? phone;
  String? accountID;
  String? pID;

  StudentModel({
    this.id,
    this.studentName,
    this.birthday,
    this.gender,
    this.phone,
    this.accountID,
    this.pID,
  });

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return StudentModel(
      id: data['_id'] ?? '',
      studentName: data['_studentName'] ?? '',
      birthday: data['_birthday'] ?? '',
      gender: data['_gender'] ?? '',
      phone: data['_phone'] ?? '',
      accountID: data['ACC_id'] ?? '',
      pID: data['P_id'] ?? '',
    );
  }
}

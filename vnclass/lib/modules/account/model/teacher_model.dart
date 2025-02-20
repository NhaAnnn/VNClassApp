import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String accID;
  final String birthday;
  final String gender;
  final String id;
  final String teacherName;
  TeacherModel({
    required this.accID,
    required this.birthday,
    required this.gender,
    required this.id,
    required this.teacherName,
  });

  factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TeacherModel(
      accID: data['ACC_id'] ?? '',
      birthday: data['_birthday'] ?? '',
      gender: data['_gender'] ?? '',
      id: data['_id'] ?? '',
      teacherName: data['_teacherName'] ?? '',
    );
  }

  @override
  String toString() {
    return 'TeachModel('
        'accID: $accID'
        'birthday: $birthday'
        'gender: $gender'
        'id: $id'
        'teacherName: $teacherName'
        ')';
  }
}

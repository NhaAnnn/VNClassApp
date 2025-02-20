import 'package:cloud_firestore/cloud_firestore.dart';

class ParentModel {
  final String accID;
  final String birthday;
  final String gender;
  final String id;
  final String teacherName;
  final String phone;
  ParentModel({
    required this.accID,
    required this.birthday,
    required this.gender,
    required this.id,
    required this.teacherName,
    required this.phone,
  });

  factory ParentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ParentModel(
      accID: data['ACC_id'] ?? '',
      birthday: data['_birthday'] ?? '',
      gender: data['_gender'] ?? '',
      id: data['_id'] ?? '',
      teacherName: data['_teacherName'] ?? '',
      phone: data['_phone'] ?? '',
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
        'phone: $phone'
        ')';
  }
}

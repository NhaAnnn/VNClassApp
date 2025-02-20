import 'package:cloud_firestore/cloud_firestore.dart';

class StudentMistakeModel {
  final String idStudent;
  final String nameStudent;
  final String gender;
  final String accid;
  final String phone;
  final String birthday;
  final String parentId;

  StudentMistakeModel({
    required this.idStudent,
    required this.nameStudent,
    required this.gender,
    required this.accid,
    required this.birthday,
    required this.phone,
    required this.parentId,
  });

  // Tạo từ tài liệu Firestore
  factory StudentMistakeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return StudentMistakeModel(
        idStudent: data['_id'] ?? 'B2103561',
        nameStudent: data['_studentName'] ?? 'Chưa có tên',
        gender: data['_gender'] ?? 'Chưa có giới tính',
        accid: data['ACC_id'] ?? 'Chưa có tài khoản',
        birthday: data['_birthday'] ?? 'Chưa có ngày sinh',
        phone: data['_phone'] ?? 'Chưa có số điện thoại',
        parentId: data['P_id'] ?? 'Chua co P_id');
  }

  @override
  String toString() {
    return 'StudentMistakeModel(idStudent: $idStudent'
        'nameStudent: $nameStudent, gender: $gender, '
        'accid: $accid, birthday: $birthday, phone: $phone,'
        ' parentid: $parentId,)';
  }
}

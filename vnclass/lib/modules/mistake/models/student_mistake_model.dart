import 'package:cloud_firestore/cloud_firestore.dart';

class StudentMistakeModel {
  final String idStudent;
  final String nameStudent;
  final String numberOfErrors;

  StudentMistakeModel({
    required this.idStudent,
    required this.nameStudent,
    required this.numberOfErrors,
  });

  // Tạo từ tài liệu Firestore
  factory StudentMistakeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return StudentMistakeModel(
      idStudent: data['names'] ?? 'B2103561',
      nameStudent: data['name'] ?? '',
      numberOfErrors: data['age'] ?? '',
    );
  }
}

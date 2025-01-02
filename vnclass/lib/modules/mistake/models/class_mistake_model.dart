import 'package:cloud_firestore/cloud_firestore.dart';

class ClassMistakeModel {
  final String className;
  final String semester;
  final String academicYear;
  final String classSize;
  final String homeroomTeacher;
  final String numberOfErrors;

  ClassMistakeModel({
    required this.className,
    required this.semester,
    required this.academicYear,
    required this.classSize,
    required this.homeroomTeacher,
    required this.numberOfErrors,
  });

  // Tạo từ tài liệu Firestore
  factory ClassMistakeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ClassMistakeModel(
      className: data['name'] ?? '',
      semester: data['semester'] ?? '',
      academicYear: data['academicYear'] ?? '',
      classSize: data['classSize'] ?? '',
      homeroomTeacher: data['homeroomTeacher'] ?? '',
      numberOfErrors: data['numberOfErrors'] ?? '',
    );
  }
}

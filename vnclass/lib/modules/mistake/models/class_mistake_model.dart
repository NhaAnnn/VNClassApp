import 'package:cloud_firestore/cloud_firestore.dart';

class ClassMistakeModel {
  final String className;
  final String idClass;
  final String idTeacher;
  final String academicYear;
  final int classSize;
  final String homeroomTeacher;
  final String numberOfErrorAll;
  final String numberOfErrorS1;
  final String numberOfErrorS2;

  ClassMistakeModel({
    required this.className,
    required this.idTeacher,
    required this.idClass,
    required this.academicYear,
    required this.classSize,
    required this.homeroomTeacher,
    required this.numberOfErrorAll,
    required this.numberOfErrorS1,
    required this.numberOfErrorS2,
  });

  // Tạo từ tài liệu Firestore
  factory ClassMistakeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ClassMistakeModel(
      className: data['_className'] ?? '',
      idClass: data['_id'] ?? '',
      idTeacher: data['T_id'] ?? '',
      academicYear: data['_year'] ?? '',
      classSize: data['_amount'] is int ? data['_amount'] : 0, // Sửa ở đây
      homeroomTeacher: data['T_name'] ?? '',
      numberOfErrorAll: data['_numberOfMisAll'] ?? '3',
      numberOfErrorS1: data['_numberOfMisS1'] ?? '1',
      numberOfErrorS2: data['_numberOfMisS2'] ?? '2',
    );
  }

  @override
  String toString() {
    return 'ClassMistakeModel{'
        'className: $className, '
        'idClass: $idClass, '
        'idTeacher: $idTeacher, '
        'academicYear: $academicYear, '
        'classSize: $classSize, '
        'homeroomTeacher: $homeroomTeacher, '
        'numberOfErrorAll: $numberOfErrorAll, '
        'numberOfErrorS1: $numberOfErrorS1, '
        'numberOfErrorS2:$numberOfErrorS2'
        '}';
  }
}

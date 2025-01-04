import 'package:cloud_firestore/cloud_firestore.dart';

class TypeMistakeModel {
  final String idType;
  final List<String> nameType;

  TypeMistakeModel({
    required this.idType,
    required this.nameType,
  });

  factory TypeMistakeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TypeMistakeModel(
      idType: data['name'] ?? '',
      nameType: data['semester'] ?? ['a', 'b', 'c'],
    );
  }
}

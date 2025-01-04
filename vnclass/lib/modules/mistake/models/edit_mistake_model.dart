import 'package:cloud_firestore/cloud_firestore.dart';

class EditMistakeModel {
  final String nameMistake;
  final String nameWriter;
  final String time;

  EditMistakeModel({
    required this.nameMistake,
    required this.nameWriter,
    required this.time,
  });

  factory EditMistakeModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return EditMistakeModel(
      nameMistake: data['name'] ?? '',
      nameWriter: data['semester'] ?? '',
      time: data['academicYear'] ?? '',
    );
  }
}

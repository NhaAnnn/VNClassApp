import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'mistake_model.dart';

class TypeMistakeModel {
  final String idType;
  final String nameType;
  final List<MistakeModel>? mistakes;
  final bool status;

  TypeMistakeModel({
    required this.idType,
    required this.nameType,
    this.mistakes,
    required this.status,
  });

  // Phương thức để tạo TypeMistakeModel từ Firestore
  static Future<TypeMistakeModel> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Lấy idType từ tài liệu
    String typeId = data['_id'] ?? '';

    // Lấy danh sách các vi phạm từ Firestore thông qua MistakeController
    List<MistakeModel> mistakes =
        await MistakeController.fetchMistakesByTypeId(typeId);

    return TypeMistakeModel(
      idType: typeId,
      nameType: data['_mistakeTypeName'] ?? '',
      mistakes: mistakes,
      status: data['_status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': idType,
      '_mistakeTypeName': nameType,
      '_status': status,
    };
  }
}

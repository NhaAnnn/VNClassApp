import 'package:cloud_firestore/cloud_firestore.dart';
import 'mistake_model.dart';

class TypeMistakeModel {
  final String idType;
  final String nameType;
  final List<MistakeModel> mistakes;
  final bool status;

  TypeMistakeModel({
    required this.idType,
    required this.nameType,
    required this.mistakes,
    required this.status,
  });

  // Phương thức để tạo TypeMistakeModel từ Firestore
  static Future<TypeMistakeModel> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Lấy idType từ tài liệu
    String typeId = data['_id'] ?? '';

    // Lấy danh sách các vi phạm từ Firestore
    List<MistakeModel> mistakes = await _fetchMistakesByTypeId(typeId);

    return TypeMistakeModel(
      idType: typeId,
      nameType: data['_mistakeTypeName'] ?? '',
      mistakes: mistakes,
      status: data['_status'] ?? false,
    );
  }

  // Phương thức tĩnh để lấy các vi phạm theo mtID
  static Future<List<MistakeModel>> _fetchMistakesByTypeId(
      String typeId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MISTAKE')
        .where('_MTID', isEqualTo: typeId) // Lọc theo mtID
        .get();

    return snapshot.docs
        .map((doc) =>
            MistakeModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

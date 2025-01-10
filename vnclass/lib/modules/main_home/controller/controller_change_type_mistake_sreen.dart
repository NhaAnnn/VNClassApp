import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';

class MistakeController {
  // Lấy danh sách các loại vi phạm từ Firestore
  Future<List<TypeMistakeModel>> fetchMistakeTypes() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('MISTAKE_TYPE')
          .where('_status', isEqualTo: true)
          .get();

      // Gọi fromFirestore như một phương thức bất đồng bộ
      List<TypeMistakeModel> mistakeTypes = await Future.wait(
        snapshot.docs
            .map((doc) async => await TypeMistakeModel.fromFirestore(doc)),
      );

      return mistakeTypes;
    } catch (e) {
      // Xử lý lỗi nếu có
      print('Failed to fetch mistake types: $e');
      return []; // Trả về danh sách rỗng trong trường hợp có lỗi
    }
  }

  // Phương thức tĩnh để lấy các vi phạm theo typeId
  static Future<List<MistakeModel>> fetchMistakesByTypeId(String typeId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MISTAKE')
        .where('MT_id', isEqualTo: typeId)
        .where('_status', isEqualTo: true) // Lọc theo mtID
        .get();

    return snapshot.docs
        .map((doc) =>
            MistakeModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }
}

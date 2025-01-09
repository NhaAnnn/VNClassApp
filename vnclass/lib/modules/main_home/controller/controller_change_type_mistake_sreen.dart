import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';

class MistakeController {
  // Lấy danh sách các loại vi phạm từ Firestore
  Future<List<TypeMistakeModel>> fetchMistakeTypes() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('MISTAKE_TYPE').get();

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
}

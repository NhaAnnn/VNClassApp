import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';

class EditMistakeModel {
  final String acc_id;
  final String acc_name;
  final String m_id;
  final String std_id;
  final String mm_id;
  final String mm_month;
  final String mm_subject;
  final String mm_time;
  final String m_name;
  final MistakeModel? mistake;

  EditMistakeModel({
    required this.acc_id,
    required this.acc_name,
    required this.m_id,
    required this.mm_id,
    required this.mm_month,
    required this.mm_subject,
    required this.mm_time,
    required this.std_id,
    required this.m_name,
    this.mistake,
  });

  // Phương thức tĩnh để tạo EditMistakeModel từ Firestore
  static Future<EditMistakeModel> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Lấy thông tin mistake từ collection MISTAKE
    String mId = data['M_id'] ?? '';
    if (mId.isEmpty) {
      throw Exception("M_id is empty for document: ${doc.id}");
    }

    // Chờ để lấy tài liệu mistake
    DocumentSnapshot mistakeDoc =
        await FirebaseFirestore.instance.collection('MISTAKE').doc(mId).get();
    MistakeModel? mistakeModel;
    if (mistakeDoc.exists) {
      mistakeModel =
          MistakeModel.fromFirestore(mistakeDoc.data() as Map<String, dynamic>);
    }

    return EditMistakeModel(
      // Khởi tạo các thuộc tính...
      acc_id: data['ACC_id'] ?? '',
      acc_name: data['ACC_name'] ?? '',
      m_id: mId,
      mm_id: data['_id'] ?? '',
      mm_month: data['_month'] ?? '',
      mm_subject: data['_subject'] ?? '',
      mm_time: data['_time'] ?? '',
      std_id: data['STD_id'] ?? '',
      m_name: data['M_name'] ?? '',
      mistake: mistakeModel,
    );
  }
}

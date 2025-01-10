import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/model/conduct_month_model.dart';

class ConductMonthController {
  Stream<List<ConductMonthModel>> streamConductMonth() {
    return FirebaseFirestore.instance
        .collection('MISTAKE_MONTH')
        .snapshots() // Lắng nghe các thay đổi
        .map((QuerySnapshot snapshot) {
      // Chuyển đổi các tài liệu thành danh sách StudentInfoModel
      return snapshot.docs.map((doc) {
        return ConductMonthModel.fromFirestore(doc);
      }).toList();
    });
  }
}

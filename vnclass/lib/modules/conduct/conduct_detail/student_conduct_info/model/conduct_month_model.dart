import 'package:cloud_firestore/cloud_firestore.dart';

class ConductMonthModel {
  String? id;
  String? studentID;
  Map<String, List<dynamic>>? months;

  ConductMonthModel({
    this.id,
    this.studentID,
    this.months,
  });

  factory ConductMonthModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null");
    }

    // String stuID = data['STDL_id'] ?? '';

    return ConductMonthModel(
      studentID: data['STDL_id'] ?? '',
      id: data['_id'] ?? '',
      months: {
        'Tháng 1': [
          data['_month']['month1'][0] ?? '', // Điểm rèn luyện
          data['_month']['month1'][1] ?? '', // Hành kiểm
        ],
        'Tháng 2': [
          data['_month']['month2'][0] ?? '',
          data['_month']['month2'][1] ?? '',
        ],
        'Tháng 3': [
          data['_month']['month3'][0] ?? '',
          data['_month']['month3'][1] ?? '',
        ],
        'Tháng 4': [
          data['_month']['month4'][0] ?? '',
          data['_month']['month4'][1] ?? '',
        ],
        'Tháng 5': [
          data['_month']['month5'][0] ?? '',
          data['_month']['month5'][1] ?? '',
        ],
        'Tháng 9': [
          data['_month']['month9'][0] ?? '',
          data['_month']['month9'][1] ?? '',
        ],
        'Tháng 10': [
          data['_month']['month10'][0] ?? '',
          data['_month']['month10'][1] ?? '',
        ],
        'Tháng 11': [
          data['_month']['month11'][0] ?? '',
          data['_month']['month11'][1] ?? '',
        ],
        'Tháng 12': [
          data['_month']['month12'][0] ?? '',
          data['_month']['month12'][1] ?? '',
        ],
      },
    );
  }
}

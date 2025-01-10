import 'package:cloud_firestore/cloud_firestore.dart';

class ConductMonthModel {
  final String? id;
  final Map<String, List<String>>? months;

  ConductMonthModel({
    this.id,
    this.months,
  });

  factory ConductMonthModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ConductMonthModel(
      id: data['_id'] ?? '',
      months: {
        'month1': List<String>.from(data['_month']['month1'] ?? []),
        'month2': List<String>.from(data['_month']['month2'] ?? []),
        'month3': List<String>.from(data['_month']['month3'] ?? []),
        'month4': List<String>.from(data['_month']['month4'] ?? []),
        'month5': List<String>.from(data['_month']['month5'] ?? []),
        'month9': List<String>.from(data['_month']['month9'] ?? []),
        'month10': List<String>.from(data['_month']['month10'] ?? []),
        'month11': List<String>.from(data['_month']['month11'] ?? []),
        'month12': List<String>.from(data['_month']['month12'] ?? []),
      },
    );
  }
}

class MistakeModel {
  final String idMistake;
  final String nameMistake;
  final bool status;
  final int minusPoint;
  final String mtID;

  MistakeModel({
    required this.idMistake,
    required this.nameMistake,
    required this.status,
    required this.mtID,
    required this.minusPoint,
  });

  factory MistakeModel.fromFirestore(Map<String, dynamic> data) {
    return MistakeModel(
      idMistake: data['_id'] ?? '',
      nameMistake: data['_mistakeName'] ?? '',
      status: data['_status'] ?? false,
      mtID: data['_MTID'] ?? '',
      minusPoint: data['_minusPoint'] ?? 0,
    );
  }
}

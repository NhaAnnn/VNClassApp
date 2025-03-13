import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/mistake/models/class_mistake_model.dart';

class MistakeRepository {
  final FirebaseFirestore firestore;

  MistakeRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ClassMistakeModel>> fetchMistakeClasses(
      String collectionName) async {
    try {
      QuerySnapshot snapshot = await firestore.collection(collectionName).get();
      return snapshot.docs
          .map((doc) => ClassMistakeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching mistake classes: $e");
      return [];
    }
  }

  Future<List<ClassMistakeModel>> fetchFilteredMistakeClasses({
    String? yearFilter,
  }) async {
    Query query = firestore.collection('CLASS');
    // Lọc theo _year
    if (yearFilter != null && yearFilter.isNotEmpty) {
      query = query.where('_year', isEqualTo: yearFilter);
    }

    try {
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ClassMistakeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching filtered mistake classes: $e");
      return [];
    }
  }

  Future<List<ClassMistakeModel>> fetchFilteredMistakeClassesByK({
    String? classFilter,
  }) async {
    Query query = firestore.collection('CLASS');

    // Lọc theo _className
    if (classFilter != null && classFilter.length >= 2) {
      String prefix =
          classFilter.substring(0, 2); // Lấy 2 ký tự đầu của classFilter
      query = query
          .where('_className', isGreaterThanOrEqualTo: prefix)
          .where('_className', isLessThanOrEqualTo: '$prefix\uf8ff');
    }

    try {
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ClassMistakeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching filtered mistake classes: $e");
      return [];
    }
  }

  Future<List<ClassMistakeModel>> fetchFilteredMistakeClassesByY({
    String? year,
  }) async {
    Query query = firestore.collection('CLASS');

    // Lọc theo _className

    query = query.where('_id', isEqualTo: year);

    try {
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ClassMistakeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching filtered mistake classes: $e");
      return [];
    }
  }
}

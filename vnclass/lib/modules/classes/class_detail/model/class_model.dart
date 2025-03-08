import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  String? id;
  String? className;
  int? amount;
  String? year;
  String? teacherID;
  String? teacherName;

  int? countConductEx;
  int? countConductGo;
  int? countConductAv;
  int? countConductWe;

  ClassModel({
    this.id,
    this.className,
    this.amount,
    this.year,
    this.teacherID,
    this.teacherName,
    this.countConductEx,
    this.countConductGo,
    this.countConductAv,
    this.countConductWe,
  });

  // Fetch class data from Firestore
  static Future<ClassModel> fetchClassFromFirestore(
      DocumentSnapshot doc) async {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null");
    }

    return ClassModel(
      id: data['_id'],
      className: data['_className'] ?? '',
      year: data['_year'] ?? '',
      amount: data['_amount'] ?? 0,
      teacherID: data['T_id'] ?? '',
      teacherName: data['T_name'] ?? '',
    );
  }

  // Convert ClassModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      '_className': className,
      '_year': year,
      '_amount': amount,
      'T_id': teacherID,
      'T_name': teacherName,
    };
  }

  // Create ClassModel from JSON
  static ClassModel fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['_id'],
      className: json['_className'],
      year: json['_year'],
      amount: json['_amount'],
      teacherID: json['T_id'],
      teacherName: json['T_name'],
    );
  }

  // Convert a list of ClassModels to JSON
  static String toJsonList(List<ClassModel> classes) {
    return jsonEncode(
        classes.map((classModel) => classModel.toJson()).toList());
  }

  // Create a list of ClassModels from JSON
  static List<ClassModel> fromJsonList(String jsonString) {
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => ClassModel.fromJson(json)).toList();
  }
}

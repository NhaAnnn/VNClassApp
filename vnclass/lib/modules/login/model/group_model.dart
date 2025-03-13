import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String idGroup;
  final String groupName;
  final Map<String, List<String>> permission;

  GroupModel({
    required this.idGroup,
    required this.groupName,
    required this.permission,
  });

  @override
  String toString() {
    return 'GroupModel{'
        'idGroup: $idGroup, '
        'groupName: $groupName, '
        'permission: $permission'
        '}';
  }

  // Factory method to create an instance from DocumentSnapshot
  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      idGroup: data['_id'] ?? '',
      groupName: data['_groupName'] ?? '',
      permission: _mapFromFirestore(data['_permission']),
    );
  }

  // Thêm factory method để khôi phục từ JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      idGroup: json['_id']?.toString() ?? '',
      groupName: json['_groupName']?.toString() ?? '',
      permission: _mapFromJson(json['_permission']),
    );
  }

  // Thêm phương thức toJson để serialize dữ liệu
  Map<String, dynamic> toJson() {
    return {
      '_id': idGroup,
      '_groupName': groupName,
      '_permission': permission,
    };
  }

  // Helper method to convert Firestore map to a Dart map with lists
  static Map<String, List<String>> _mapFromFirestore(dynamic permissionsData) {
    if (permissionsData is Map<String, dynamic>) {
      return permissionsData.map((key, value) {
        if (value is List) {
          return MapEntry(key, List<String>.from(value));
        }
        return MapEntry(key, []);
      });
    }
    return {};
  }

  // Helper method to convert JSON map to a Dart map with lists
  static Map<String, List<String>> _mapFromJson(dynamic permissionsData) {
    if (permissionsData is Map<String, dynamic>) {
      return permissionsData.map((key, value) {
        if (value is List) {
          return MapEntry(key, List<String>.from(value));
        }
        return MapEntry(key, []);
      });
    }
    return {};
  }
}

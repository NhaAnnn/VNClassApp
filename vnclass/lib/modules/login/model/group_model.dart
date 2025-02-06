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
}

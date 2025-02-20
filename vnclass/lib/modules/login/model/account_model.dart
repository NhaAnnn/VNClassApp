import 'package:cloud_firestore/cloud_firestore.dart';
import 'group_model.dart'; // Đảm bảo import đúng đường dẫn

class AccountModel {
  final String email;
  final String goupID;
  final String idAcc;
  final String passWord;
  final List<String> permission;
  final String phone;
  final String status;
  final String accName;
  final String userName;
  GroupModel? groupModel;
  final String gender;
  final String birth;
  final List<String>? token;

  AccountModel({
    required this.email,
    required this.goupID,
    required this.idAcc,
    required this.accName,
    required this.passWord,
    required this.permission,
    required this.phone,
    required this.status,
    required this.userName,
    required this.birth,
    required this.gender,
    this.groupModel,
    this.token,
  });

  // Factory method to create an instance from DocumentSnapshot
  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AccountModel(
      email: data['_email'] ?? '',
      accName: data['_accName'] ?? '',
      goupID: data['_groupID'] ?? '',
      idAcc: data['_id'] ?? '',
      passWord: data['_pass'] ?? '',
      permission: List<String>.from(data['_permission'] ?? []),
      phone: data['_phone'] ?? '',
      status: data['_status'] ?? '',
      userName: data['_userName'] ?? '',
      birth: data['_birth'] ?? '',
      gender: data['_gender'] ?? '',
      groupModel: null, // Khởi tạo với null, sẽ cập nhật sau
      token: List<String>.from(data['_token'] ?? []),
    );
  }

  // Fetch the GroupModel using goupID
  Future<void> fetchGroupModel() async {
    print('Fetching group model for goupID: $goupID');
    if (goupID.isNotEmpty) {
      try {
        QuerySnapshot groupQuery = await FirebaseFirestore.instance
            .collection('GROUP')
            .where('_id', isEqualTo: goupID)
            .get();

        if (groupQuery.docs.isNotEmpty) {
          DocumentSnapshot groupDoc = groupQuery.docs.first;
          groupModel =
              GroupModel.fromFirestore(groupDoc); // Cập nhật groupModel
          print('Fetching group model for goupID: $groupModel');
        } else {
          print('No group found for goupID: $goupID');
        }
      } catch (e) {
        print('Error fetching group model: $e');
      }
    }
  }

  @override
  String toString() {
    return 'AccountModel{'
        'email: $email, '
        'goupID: $goupID, '
        'idAcc: $idAcc, '
        'passWord: $passWord, '
        'permission: $permission, '
        'phone: $phone, '
        'status: $status, '
        'userName: $userName, '
        'groupModel: ${groupModel != null ? groupModel.toString() : "No Group"}'
        'token:$token'
        '}';
  }
}

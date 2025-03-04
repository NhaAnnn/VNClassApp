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
    final data = doc.data() as Map<String, dynamic>?; // Kiểm tra null cho data

    return AccountModel(
      email: data?['_email']?.toString() ?? '',
      accName: data?['_accName']?.toString() ?? '',
      goupID: data?['_groupID']?.toString() ?? '',
      idAcc: data?['_id']?.toString() ?? '',
      passWord: data?['_pass']?.toString() ?? '',
      permission: List<String>.from(data?['_permission'] ?? []),
      phone: data?['_phone']?.toString() ?? '',
      status: data?['_status']?.toString() ?? '',
      userName: data?['_userName']?.toString() ?? '',
      birth: data?['_birth']?.toString() ?? '',
      gender: data?['_gender']?.toString() ?? '',
      groupModel: null, // Khởi tạo với null, sẽ cập nhật sau
      token: data?['_token'] != null ? List<String>.from(data!['_token']) : [],
    );
  }

  // Fetch the GroupModel using goupID with optimization
  Future<void> fetchGroupModel({int retries = 2}) async {
    if (goupID.isEmpty || groupModel != null)
      return; // Tránh fetch không cần thiết

    print('Fetching group model for goupID: $goupID');
    for (int i = 0; i <= retries; i++) {
      try {
        QuerySnapshot groupQuery = await FirebaseFirestore.instance
            .collection('GROUP')
            .where('_id', isEqualTo: goupID)
            .limit(1) // Chỉ lấy 1 document để tăng tốc
            .get(
                GetOptions(source: Source.serverAndCache)); // Dùng cache nếu có

        if (groupQuery.docs.isNotEmpty) {
          groupModel = GroupModel.fromFirestore(groupQuery.docs.first);
          print('Fetched group model: $groupModel');
          break;
        } else {
          print('No group found for goupID: $goupID');
          break;
        }
      } catch (e) {
        print('Error fetching group model (attempt ${i + 1}): $e');
        if (i == retries)
          throw Exception(
              'Failed to fetch group model after $retries attempts');
        await Future.delayed(
            Duration(milliseconds: 300 * (i + 1))); // Delay tăng dần
      }
    }
  }

  // Thêm toJson để hỗ trợ lưu trữ
  Map<String, dynamic> toJson() => {
        '_email': email.isNotEmpty ? email : null,
        '_groupID': goupID.isNotEmpty ? goupID : null, // Giữ tên field cũ
        '_id': idAcc.isNotEmpty ? idAcc : null,
        '_pass': passWord.isNotEmpty ? passWord : null,
        '_permission': permission.isNotEmpty ? permission : [],
        '_phone': phone.isNotEmpty ? phone : null,
        '_status': status.isNotEmpty ? status : null,
        '_accName': accName.isNotEmpty ? accName : null,
        '_userName': userName.isNotEmpty ? userName : null,
        '_birth': birth.isNotEmpty ? birth : null,
        '_gender': gender.isNotEmpty ? gender : null,
        '_token': token?.isNotEmpty ?? false ? token : null,
      };

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
        'groupModel: ${groupModel != null ? groupModel.toString() : "No Group"}, '
        'token: $token'
        '}';
  }
}

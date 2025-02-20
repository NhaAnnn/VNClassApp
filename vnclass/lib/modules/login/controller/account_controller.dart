import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

class AccountController {
  Future<AccountModel> fetchAccount(String username, String passHash) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ACCOUNT')
          .where('_userName', isEqualTo: username)
          .where('_pass', isEqualTo: passHash)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        AccountModel account = AccountModel.fromFirestore(doc);
        return account;
      } else {
        throw Exception('No account found for the given credentials.');
      }
    } catch (e) {
      print('Failed to fetch mistake types: $e');
      rethrow; // Ném lại lỗi để xử lý ở nơi khác nếu cần
    }
  }

  Future<List<String>> fetchTokens(String id) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ACCOUNT')
          .where('_id', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        AccountModel account = AccountModel.fromFirestore(doc);

        return account.token ?? [];
      } else {
        throw Exception('No account found for the given credentials.');
      }
    } catch (e) {
      print('Failed to fetch tokens: $e');
      rethrow;
    }
  }

  static Future<void> updateToken(String id, String newToken) async {
    try {
      // Tìm tài liệu theo ACC_id hoặc _id
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ACCOUNT')
          .where('_id', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;

        // Cập nhật hoặc thêm token vào danh sách token
        List<String> currentTokens = List<String>.from(doc['tokens'] ?? []);
        currentTokens.add(newToken); // Thêm token mới vào danh sách

        // Cập nhật tài liệu
        await doc.reference.update({'tokens': currentTokens});
        print('Token đã được cập nhật thành công.');
      } else {
        print('Không tìm thấy tài liệu với _id: $id');
      }
    } catch (e) {
      print('Lỗi khi cập nhật token: $e');
    }
  }
}

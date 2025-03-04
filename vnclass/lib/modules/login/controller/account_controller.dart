import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

class AccountController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AccountModel> fetchAccount(String username, String passHash) async {
    try {
      print(
          'Fetching account with username: "$username", passHash: "$passHash"');
      final QuerySnapshot snapshot = await _firestore
          .collection('ACCOUNT')
          .where('_userName', isEqualTo: username)
          .where('_pass', isEqualTo: passHash)
          .limit(1)
          .get(GetOptions(source: Source.serverAndCache));

      print('Snapshot size: ${snapshot.docs.length}');
      if (snapshot.docs.isNotEmpty) {
        final DocumentSnapshot doc = snapshot.docs.first;
        print('Found document: ${doc.data()}');
        final AccountModel account = AccountModel.fromFirestore(doc);
        return account;
      } else {
        throw Exception('No account found for the given credentials.');
      }
    } catch (e) {
      print('Failed to fetch account: $e');
      rethrow;
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
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('ACCOUNT')
          .where('_id', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;

        List<String> currentTokens = List<String>.from(doc['tokens'] ?? []);
        currentTokens.add(newToken);

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

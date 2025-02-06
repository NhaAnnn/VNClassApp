import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

class AccountController {
  Future<AccountModel> fetchAccount(
      String username, String passHash) async {
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
}

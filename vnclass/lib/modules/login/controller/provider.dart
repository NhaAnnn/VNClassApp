import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'dart:convert';

class AccountProvider with ChangeNotifier {
  AccountModel? _account;

  AccountModel? get account => _account;

  void setAccount(AccountModel account) {
    _account = account;
    notifyListeners();
    // Thêm logic lưu vào SharedPreferences cho phiên bản web
    _saveAccountToPrefs();
  }

  // Thêm phương thức để lưu dữ liệu vào SharedPreferences
  Future<void> _saveAccountToPrefs() async {
    if (_account == null) return;
    final prefs = await SharedPreferences.getInstance();
    final accountJson = jsonEncode(_account!.toJson());
    await prefs.setString('account', accountJson);
  }

  // Thêm phương thức để khôi phục dữ liệu từ SharedPreferences
  Future<void> loadAccountFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final accountJson = prefs.getString('account');

    if (accountJson != null) {
      final decodedMap = jsonDecode(accountJson) as Map<String, dynamic>;
      final account = AccountModel.fromJson(decodedMap);
      await account.fetchGroupModel(
          retries: 1); // Cập nhật groupModel từ Firestore
      _account = account;
      notifyListeners();
    }
  }

  // Thêm phương thức để xóa dữ liệu khi đăng xuất
  Future<void> clearAccount() async {
    _account = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account');
    notifyListeners();
  }
}

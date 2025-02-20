import 'package:flutter/material.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

class AccountProvider with ChangeNotifier {
  AccountModel? _account;

  AccountModel? get account => _account;

  void setAccount(AccountModel account) {
    _account = account;
    notifyListeners(); // Cập nhật UI khi account thay đổi
  }
}

import 'package:flutter/material.dart';

class PermissionProvider with ChangeNotifier {
  List<String> _permission = []; // Private để lưu quyền
  List<String> get permission => _permission; // Getter

  void setPermission(List<String> pers) {
    _permission = List.from(pers); // Gán danh sách mới
    print('Quyền trong PermissionProvider: $_permission'); // Debug
    notifyListeners(); // Thông báo thay đổi
  }
}

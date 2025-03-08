import 'package:flutter/material.dart';

class PermissionProvider with ChangeNotifier {
  List<String> permission = []; // Danh sách năm học

  void setPermission(List<String> pers) {
    permission.addAll(pers);
    // print('du lieu perjskfnvkdv+$permission');
  }
}

import 'package:flutter/material.dart';

class NotificationChange with ChangeNotifier {
  static int _unreadCount = 0;

  static int get unreadCount => _unreadCount;

  // Thiết lập số lượng chưa đọc
  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  // Tăng số lượng chưa đọc
  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners();
  }

  // Giảm số lượng chưa đọc
  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }
}

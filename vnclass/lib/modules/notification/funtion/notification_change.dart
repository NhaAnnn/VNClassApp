import 'package:flutter/material.dart';

class NotificationChange with ChangeNotifier {
  int _unreadCount = 0; // Không cần static

  // Getter cho số lượng chưa đọc
  int get unreadCount => _unreadCount; // Không cần static

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

  // Đặt lại số lượng chưa đọc
  void resetUnreadCount() {
    _unreadCount = 0;
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

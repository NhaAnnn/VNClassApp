import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> notificationDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Bật thông báo!!!'),
        content: Text(
          'Để nhận thông báo từ ứng dụng, vui lòng bật thông báo trong cài đặt.',
          style: TextStyle(fontSize: 14),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('Cài đặt'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              openAppSettings(); // Open the app settings
            },
          ),
        ],
      );
    },
  );
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_service.dart';

class SendNotificationParentDialog extends StatefulWidget {
  const SendNotificationParentDialog({super.key, required this.pID});

  final String pID;

  @override
  State<SendNotificationParentDialog> createState() =>
      _SendNotificationParentDialogState();
}

class _SendNotificationParentDialogState
    extends State<SendNotificationParentDialog> {
  String title = '';
  String content = '';

  String? titleError;
  String? contentError;

  void _validateInputs() {
    setState(() {
      titleError = title.isEmpty ? 'Vui lòng nhập tiêu đề thông báo' : null;
      contentError = content.isEmpty ? 'Vui lòng nội dung thông báo' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Gửi Thông Báo',
        style: TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextfieldWidget(
              labelText: 'Tiêu đề thông báo',
              colorBorder: Color(0xFF666666),
              onChanged: (value) {
                title = value;
                titleError = null;
              },
              errorText: titleError,
              onTap: () {
                setState(() {
                  titleError = null; // Ẩn thông báo lỗi
                });
              },
            ),
            SizedBox(height: 8),
            TextfieldWidget(
              maxLines: 3,
              labelText: 'Nội dung thông báo',
              colorBorder: Color(0xFF666666),
              onChanged: (value) {
                content = value;
                contentError = null; // Xóa lỗi khi người dùng nhập
              },
              errorText: contentError,
              onTap: () {
                setState(() {
                  contentError = null; // Ẩn thông báo lỗi
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            _validateInputs();
            if (titleError != null || contentError != null) {
              return; // Dừng lại nếu có lỗi
            }

            try {
              List<String> deviceTokens =
                  await AccountController.fetchTokens(widget.pID);
              NotificationService.sendNotification(
                  widget.pID, deviceTokens, title, content);
              await NotificationController.createNotification(
                  widget.pID, title, content);
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Gửi thông báo thành công!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } catch (e) {
              print('Error: $e');
            }
            print('Tiêu đề: $title');
            print('Nội dung: $content');

            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            fixedSize: Size(
              kIsWeb
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.2,
              MediaQuery.of(context).size.height * 0.05,
            ),
          ),
          child: const Text(
            'Gửi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
            fixedSize: Size(
              kIsWeb
                  ? MediaQuery.of(context).size.width * 0.05
                  : MediaQuery.of(context).size.width * 0.2,
              MediaQuery.of(context).size.height * 0.05,
            ),
          ),
          child: const Text(
            'Đóng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

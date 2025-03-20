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
                titleError = null; // Xóa lỗi khi người dùng nhập
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
        ButtonN(
          ontap: () async {
            _validateInputs();
            if (titleError != null || contentError != null) {
              return; // Dừng lại nếu có lỗi
            }

            try {
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

              List<String> deviceTokens =
                  await AccountController.fetchTokens(widget.pID);
              NotificationService.sendNotification(
                  widget.pID, deviceTokens, title, content);
            } catch (e) {
              print('Error: $e');
            }
            // Implement your send logic
            print('Tiêu đề: $title');
            print('Nội dung: $content');

            Navigator.of(context).pop(); // Close the dialog after sending
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Gửi',
          color: Colors.blue,
          colorText: Colors.white,
        ),
        ButtonN(
          ontap: () {
            Navigator.of(context).pop();
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Đóng',
          color: Colors.red,
          colorText: Colors.white,
        ),
      ],
    );
  }
}

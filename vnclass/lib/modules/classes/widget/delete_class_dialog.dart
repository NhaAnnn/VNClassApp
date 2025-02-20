import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';

class DeleteClassDialog extends StatefulWidget {
  const DeleteClassDialog({
    super.key,
    required this.classId,
    required this.onDelete,
  });

  final String classId;
  final VoidCallback onDelete;

  @override
  State<DeleteClassDialog> createState() => _DeleteClassDialogState();
}

class _DeleteClassDialogState extends State<DeleteClassDialog> {
  String get classId => widget.classId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Xóa lớp học:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Text(
        'Xác nhận xóa lớp học và toàn bộ thông tin về lớp học?',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        ButtonN(
          ontap: () async {
            try {
              // Gọi xóa lớp học trước
              await ClassController.deleteClass(classId);

              // Gọi hàm onDelete sau khi xóa thành công
              widget.onDelete();

              // Hiện thông báo thành công
              Navigator.of(context).pop(); // Đóng dialog xóa
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Thông báo'),
                    content: Text('Xóa lớp học thành công!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog thông báo
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            } catch (e) {
              // Hiện thông báo thất bại
              Navigator.of(context).pop(); // Đóng dialog xóa
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Lỗi'),
                    content: Text('Xóa lớp học thất bại!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog thông báo
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Xóa',
          colorText: Colors.white,
          color: Colors.red,
        ),
        ButtonN(
          ontap: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Hủy',
          colorText: Colors.white,
          color: Colors.blue,
        ),
      ],
    );
  }
}

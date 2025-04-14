import 'package:flutter/foundation.dart';
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
      content: SizedBox(
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.2
            : MediaQuery.of(context).size.width * 0.8,
        child: Text(
          'Xác nhận xóa lớp học và toàn bộ thông tin về lớp học?',
          style: TextStyle(color: Colors.black),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            try {
              await ClassController.deleteClass(classId);
              widget.onDelete();
              Navigator.of(context).pop();
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
            'Xóa',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
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
            'Hủy',
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

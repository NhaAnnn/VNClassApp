import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';

class DeleteClassDialog extends StatefulWidget {
  const DeleteClassDialog({super.key});

  @override
  State<DeleteClassDialog> createState() => _DeleteClassDialogState();
}

class _DeleteClassDialogState extends State<DeleteClassDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Xóa lớp học:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: Text(
        'Xác nhận xóa lớp học và toàn bộ thông tin về lớp học??',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        ButtonN(
          ontap: () {
            Navigator.of(context).pop();
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Xóa',
          color: Colors.red,
        ),
        ButtonN(
          ontap: () {
            Navigator.of(context).pop();
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Hủy',
          color: Colors.blue,
        ),
      ],
    );
  }
}

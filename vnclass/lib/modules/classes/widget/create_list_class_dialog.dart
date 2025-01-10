import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';

class CreateListClassDialog extends StatefulWidget {
  const CreateListClassDialog({super.key});

  @override
  State<CreateListClassDialog> createState() => _CreateListClassDialogState();
}

class _CreateListClassDialogState extends State<CreateListClassDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Thêm Danh sách lớp học:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: TextfieldWidget(
                          labelText: 'File danh sách lớp',
                          // controller: ,
                        ),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    Expanded(
                      flex: 3,
                      child: ButtonN(
                        label: 'Chọn file',
                        color: Colors.cyanAccent.shade700,
                      ),
                    )
                  ],
                ),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              ]),
        ),
      ),
      actions: [
        ButtonN(
          // textAlign: TextAlign.center,
          ontap: () {
            Navigator.of(context).pop();
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Lưu',
          color: Colors.blueAccent,
        ),
        ButtonN(
          // textAlign: TextAlign.center,
          ontap: () {
            Navigator.of(context).pop();
          },
          size: Size(
            MediaQuery.of(context).size.width * 0.2,
            MediaQuery.of(context).size.height * 0.05,
          ),
          label: 'Đóng',
          color: Colors.red,
        ),
      ],
    );
  }
}

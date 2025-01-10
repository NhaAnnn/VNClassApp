import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';

class UpdateClassDialog extends StatefulWidget {
  const UpdateClassDialog({super.key});

  @override
  State<UpdateClassDialog> createState() => _UpdateClassDialogState();
}

class _UpdateClassDialogState extends State<UpdateClassDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Chỉnh sửa lớp học:',
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
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextfieldWidget(
                          labelText: 'Lớp học:',
                          // controller: ,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextfieldWidget(
                          // controller: ,
                          labelText: 'GVCN',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TextfieldWidget(
                          // controller: ,
                          labelText: 'Niên khóa',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ]),
        ),
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
          label: 'Sửa',
          color: Colors.blue,
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
        ),
      ],
    );
  }
}

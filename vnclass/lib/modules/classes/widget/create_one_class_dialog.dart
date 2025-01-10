import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';

class CreateOneClassDialog extends StatefulWidget {
  const CreateOneClassDialog({super.key});

  @override
  State<CreateOneClassDialog> createState() => _CreateOneClassDialogState();
}

class _CreateOneClassDialogState extends State<CreateOneClassDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        'Thêm lớp học:',
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
                      child: TextfieldWidget(
                        labelText: 'Lớp học:',
                        // controller: ,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: TextfieldWidget(
                        // controller: ,
                        labelText: 'GVCN',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  children: [
                    Expanded(
                      child: TextfieldWidget(
                        // controller: ,
                        labelText: 'Niên khóa',
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
          label: 'Thêm',
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

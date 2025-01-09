import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/check_btn_widget.dart';

class DialogPermisstion extends StatefulWidget {
  const DialogPermisstion({super.key});

  @override
  State<DialogPermisstion> createState() => _DialogPermisstionState();
}

class _DialogPermisstionState extends State<DialogPermisstion> {
  List<String> _selectedOptions = [];

  void _handleCheckboxChange(List<String> selectedOptions) {
    setState(() {
      _selectedOptions = selectedOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chọn Thông Tin',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Các quyền: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                      child: CheckBoxWidget(
                    options: ['Option 1', 'Option 2', 'Option 3'],
                    onChanged: _handleCheckboxChange,
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            ButtonWidget(title: 'Lưu thay đổi'),
            ButtonWidget(
              title: 'Thoát',
              color: Colors.red,
              ontap: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ],
    );
  }
}

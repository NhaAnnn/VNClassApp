import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';

class DialogExportAcc extends StatefulWidget {
  const DialogExportAcc({super.key});

  @override
  State<DialogExportAcc> createState() => _DialogExportAccState();
}

class _DialogExportAccState extends State<DialogExportAcc> {
  String? selectedOption;

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
                  Text('Loại tài khoản: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: RadioButtonWidget(
                      options: [
                        'Học sinh - PHHS',
                        'Giáo viên',
                        'Ban giám hiệu',
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.red,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      spreadRadius: 4,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          'Dữ liệu xuất',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: ButtonWidget(
                          title: 'Xuất file',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            ButtonWidget(title: 'Tải xuống'),
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

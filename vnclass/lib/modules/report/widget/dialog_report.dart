import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';

class DialogReport extends StatefulWidget {
  const DialogReport({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DialogReport createState() => _DialogReport();
}

class _DialogReport extends State<DialogReport> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chọn Thông Tin',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Xuất theo: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: RadioButtonWidget(
                      options: ['Tháng', 'Học kỳ'],
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
              if (selectedOption == 'Tháng') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Chọn tháng',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(
                      child: DropMenuWidget(
                        hintText: 'Tháng',
                        items: [
                          'Tháng 1',
                          'Tháng 2',
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
              if (selectedOption == 'Học kỳ') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Chọn học kỳ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Expanded(
                      child: RadioButtonWidget(
                        options: [
                          'Học kỳ 1',
                          'Học kỳ 2',
                          'Cả Năm',
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
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
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Đóng', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}

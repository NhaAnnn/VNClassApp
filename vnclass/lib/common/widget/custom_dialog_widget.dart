import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';

class CustomDialogWidget extends StatelessWidget {
  const CustomDialogWidget({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialogWidget();
      },
    );
  }

  static void showDeleteConfirmationDialog(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Bạn chắc chắn muốn xóa chứ?',
      showConfirmBtn: false,
      widget: Padding(
        padding: const EdgeInsets.all(16.0), // Khoảng cách bên trong
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ButtonWidget(
                title: 'Cancel',
                color: Colors.red,
              ),
            ),
            Spacer(),
            Expanded(
              child: ButtonWidget(
                title: 'Okey',
              ),
            )
          ],
        ),
      ),
    );
  }

  static void showCustomAlert(BuildContext context) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.custom,
      title: 'TD',
      widget: Column(
        children: [
          Row(
            children: [
              Text('Xuất theo: '),
              Expanded(
                child: RadioButtonWidget(
                  options: ['Tháng', 'Học kỳ'],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('Chọn tháng'),
              Expanded(
                child: DropMenuWidget(
                  hintText: 'Tháng',
                  items: ['Tháng 1', 'Tháng 2'],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text('Chọn học kỳ'),
              Expanded(
                child: RadioButtonWidget(
                  options: ['Học kỳ 1', 'Học kỳ 2', 'Cả Năm'],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red, width: 1),
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 6,
                    child: Text('data'),
                  ),
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
      confirmBtnText: 'Đóng',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );
  }

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
          // Thêm cuộn nếu nội dung quá dài
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Đảm bảo chiều cao của Column chỉ bao gồm nội dung
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Xuất theo: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(
                    child: RadioButtonWidget(
                      options: ['Tháng', 'Học kỳ'],
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10), // Khoảng cách giữa các Row
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
              SizedBox(height: 15), // Khoảng cách trước Container
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
                      SizedBox(width: 10), // Khoảng cách giữa Text và Button
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

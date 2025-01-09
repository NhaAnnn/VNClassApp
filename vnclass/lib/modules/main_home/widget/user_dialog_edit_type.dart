import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';

class UserDialogEditType extends StatefulWidget {
  const UserDialogEditType({
    super.key,
    this.showBtnDelete = true,
    this.mistakeDialog = false,
    this.mistake, // Giá trị mặc định là true
  });

  final bool showBtnDelete; // Đổi thành non-nullable
  final bool mistakeDialog;
  final MistakeModel? mistake;
  @override
  State<UserDialogEditType> createState() => _UserDialogEditTypeState();
}

class _UserDialogEditTypeState extends State<UserDialogEditType> {
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
                children: [
                  Expanded(
                    child: DropMenuWidget(
                      items: ['1', '2'],
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.02), // Khoảng cách giữa các widget
              Row(
                children: [
                  Expanded(
                    child:
                        TextfieldWidget(labelText: widget.mistake!.nameMistake),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextfieldWidget(labelText: 'Điểm Trừ'),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: ButtonWidget(title: 'Chỉnh sửa')),
                  SizedBox(width: 8), // Khoảng cách giữa hai nút
                  Expanded(
                    child: ButtonWidget(
                      title: 'Thoát',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              if (widget.showBtnDelete) ...[
                // Sử dụng widget.showBtnDelete
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(title: 'Xóa Vi Phạm'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

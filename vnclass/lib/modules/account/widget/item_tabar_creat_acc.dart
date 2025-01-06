import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';

class ItemTabarCreatAcc extends StatefulWidget {
  final bool show; // Thêm biến show để kiểm soát hiển thị

  const ItemTabarCreatAcc({super.key, required this.show});

  @override
  State<ItemTabarCreatAcc> createState() => _ItemTabarCreatAccState();
}

class _ItemTabarCreatAccState extends State<ItemTabarCreatAcc> {
  final TextEditingController _dateController = TextEditingController();
  bool _isShowPass = false;
  bool _isShowPassAgain = false;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  void onToggleShowPass() {
    setState(() {
      _isShowPass = !_isShowPass;
    });
  }

  void onToggleShowPassAgain() {
    setState(() {
      _isShowPassAgain = !_isShowPassAgain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          // Hiển thị "Lớp" và "Năm học" chỉ nếu widget.show là true
          if (widget.show) ...[
            TextfieldWidget(labelText: 'Lớp'),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              children: [
                Text('Năm học:'),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Expanded(
                  child: DropMenuWidget(items: ['2024-2025']),
                ),
              ],
            ),
          ],
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(labelText: 'Tên người dùng'),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(labelText: 'Mã viên chức'),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextField(
            controller: _dateController,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Date',
              fillColor: Colors.white,
              suffixIcon: Icon(FontAwesomeIcons.calendar),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorApp.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            readOnly: true,
            onTap: () {
              _selectDate();
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              Text('Giới tính:'),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              Expanded(
                  child: RadioButtonWidget(
                      options: ['Nam', 'Nữ'], onChanged: (value) {})),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              Text('Chức vụ:'),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              Expanded(
                child: RadioButtonWidget(
                    options: ['Ban giám hiệu'], onChanged: (value) {}),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(labelText: 'Tên tài khoản'),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    TextField(
                      obscureText: !_isShowPass,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: ColorApp.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 29, 92, 252),
                              width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorApp.primaryColor, width: 2.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: onToggleShowPass,
                        child: Icon(
                          _isShowPass
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),

          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    TextField(
                      obscureText: !_isShowPassAgain,
                      decoration: InputDecoration(
                        labelText: 'Nhập lại mật khẩu',
                        labelStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: ColorApp.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 29, 92, 252),
                              width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorApp.primaryColor, width: 2.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: onToggleShowPassAgain,
                        child: Icon(
                          _isShowPassAgain
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),

          Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  title: 'Tạo tài khoản',
                  ontap: () => CustomDialogWidget.showConfirmationDialog(
                      context, 'Xác nhận tạo tài khoản?'),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';

class UserChangePassScreen extends StatefulWidget {
  const UserChangePassScreen({super.key});

  static const String routeName = '/user_change_pass_screen';
  @override
  State<UserChangePassScreen> createState() => _UserChangePassScreenState();
}

class _UserChangePassScreenState extends State<UserChangePassScreen> {
  bool _isShowPass = false;
  bool _isShowPassNew = false;
  bool _isShowPassAgain = false;
  void onToggleShowPass() {
    setState(() {
      _isShowPass = !_isShowPass;
    });
  }

  void onToggleShowPassNew() {
    setState(() {
      _isShowPassNew = !_isShowPassNew;
    });
  }

  void onToggleShowPassAgain() {
    setState(() {
      _isShowPassAgain = !_isShowPassAgain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Đổi mật khẩu',
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
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
                          labelText: 'Mật khẩu cũ',
                          labelStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: ColorApp.primaryColor),
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
                        obscureText: !_isShowPass,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          labelStyle: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: ColorApp.primaryColor),
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
                          onTap: onToggleShowPassNew,
                          child: Icon(
                            _isShowPassNew
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
                            borderSide:
                                BorderSide(color: ColorApp.primaryColor),
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
                    title: 'Lưu Thay Đổi',
                    ontap: () => CustomDialogWidget.showConfirmationDialog(
                        context, 'Xác nhận thay đổi mật khẩu?'),
                  ),
                ),
                Expanded(
                  child: ButtonWidget(
                    title: 'Thoát',
                    color: Colors.red,
                    ontap: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}

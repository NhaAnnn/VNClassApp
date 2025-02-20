import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for utf8.encode
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = false; // Biến trạng thái cho ProgressBar

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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

  // Hàm băm mật khẩu
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Hàm thay đổi mật khẩu
  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true; // Hiện ProgressBar
    });

    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Băm mật khẩu cũ
    String hashedOldPassword = _hashPassword(oldPassword);

    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    final account = accountProvider.account;

    // Kiểm tra mật khẩu cũ
    if (hashedOldPassword == account!.passWord) {
      if (newPassword == confirmPassword) {
        // Cập nhật mật khẩu mới vào Firestore
        String hashedNewPassword = _hashPassword(newPassword);

        var snapshot = await FirebaseFirestore.instance
            .collection('ACCOUNT')
            .where('_id', isEqualTo: account.idAcc)
            .get();
        if (snapshot.docs.isNotEmpty) {
          // Cập nhật tài liệu đầu tiên tìm thấy
          await snapshot.docs.first.reference
              .update({'_pass': hashedNewPassword});
        } else {
          print('No document found with the provided ID.');
        }

        // Hiển thị thông báo thành công
        CustomDialogWidget.showConfirmationDialog(
            context, 'Mật khẩu đã được cập nhật!');
      } else {
        // Hiển thị thông báo mật khẩu không khớp
        CustomDialogWidget.showConfirmationDialog(
            context, 'Mật khẩu mới không khớp!');
      }
    } else {
      // Hiển thị thông báo mật khẩu cũ không đúng
      CustomDialogWidget.showConfirmationDialog(
          context, 'Mật khẩu cũ không đúng!');
    }

    setState(() {
      _isLoading = false; // Ẩn ProgressBar
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Đổi mật khẩu',
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          TextField(
                            controller: _oldPasswordController,
                            obscureText: !_isShowPass,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu cũ',
                              labelStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: ColorApp.primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 29, 92, 252),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          TextField(
                            controller: _newPasswordController,
                            obscureText: !_isShowPassNew,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu mới',
                              labelStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: ColorApp.primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 29, 92, 252),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: !_isShowPassAgain,
                            decoration: InputDecoration(
                              labelText: 'Nhập lại mật khẩu',
                              labelStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: ColorApp.primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 29, 92, 252),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        title: 'Lưu Thay Đổi',
                        ontap: () {
                          CustomDialogWidget.showConfirmationDialog(
                            context,
                            'Xác nhận thay đổi mật khẩu?',
                            onTapOK: () {
                              _changePassword();
                            },
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ButtonWidget(
                        title: 'Thoát',
                        color: Colors.red,
                        ontap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              ],
            ),
          ),
          if (_isLoading) // Hiện ProgressBar khi đang tải
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

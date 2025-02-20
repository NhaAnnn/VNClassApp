import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart'; // Import AccountController
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/main_home/views/main_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String routeName = 'login_page';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;
  bool _isShowPass = false;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AccountController _accountController =
      AccountController(); // Tạo instance

  void _onChanged(bool? newValue) {
    setState(() {
      _isChecked = newValue ?? false;
    });
  }

  void _toggleShowPass() {
    setState(() {
      _isShowPass = !_isShowPass;
    });
  }

  void _login() async {
    final String username = _userNameController.text.trim();
    final String password = _passwordController.text.trim();
    final String passHash = _hashPassword(password);

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Tên đăng nhập hoặc mật khẩu không được để trống');
      return;
    }

    try {
      // Sử dụng AccountController để lấy thông tin tài khoản
      AccountModel account =
          await _accountController.fetchAccount(username, passHash);
      await account.fetchGroupModel();
      Provider.of<AccountProvider>(context, listen: false).setAccount(account);
      Navigator.of(context).pushNamed(MainHomePage.routeName);
    } catch (e) {
      _showMessage('Đã xảy ra lỗi, vui lòng thử lại');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            ImageHelper.loadFromAsset(
              AssetHelper.imageLogoSplashScreen,
              width: 180,
              height: 180,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'Tên Đăng Nhập',
                labelStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorApp.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 29, 92, 252), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorApp.primaryColor, width: 2.0),
                ),
                prefixIcon: const Icon(
                  Icons.person_outline_outlined,
                  size: 28,
                  color: Color.fromARGB(255, 29, 92, 252),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: !_isShowPass,
                  decoration: InputDecoration(
                    labelText: 'Mật Khẩu',
                    labelStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w300),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ColorApp.primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 29, 92, 252), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: ColorApp.primaryColor, width: 2.0),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      size: 28,
                      color: Color.fromARGB(255, 29, 92, 252),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: GestureDetector(
                    onTap: _toggleShowPass,
                    child: Icon(
                      _isShowPass
                          ? FontAwesomeIcons.eye
                          : FontAwesomeIcons.eyeSlash,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: _onChanged,
                ),
                const Text(
                  'Ghi Nhớ Đăng Nhập',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ButtonWidget(
              title: 'Đăng Nhập',
              ontap: _login,
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.centerRight,
              child: const Text(
                'Quên mật khẩu ?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 11, 155, 239),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

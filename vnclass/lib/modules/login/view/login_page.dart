import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/button_widget.dart';
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
  final TextEditingController _userName = TextEditingController();
  final TextEditingController _passWord = TextEditingController();

  void _onChanged(bool? newValue) {
    setState(() {
      _isChecked = newValue ?? false; // Cập nhật trạng thái
    });
  }

  void onToggleShowPass() {
    setState(() {
      _isShowPass = !_isShowPass;
    });
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _addData() async {
    for (int i = 0; i < 5; i++) {
      try {
        await firestore.collection('users').add({
          'name': 'John Doe $i',
          'age': 30,
          'email': 'john.doe@example.com',
        });
        print('Document added successfully');
      } catch (e) {
        print('Error adding document: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Căn giữa theo chiều dọc
          crossAxisAlignment:
              CrossAxisAlignment.center, // Căn giữa theo chiều ngang
          children: [
            SizedBox(height: 50), // Thêm khoảng cách trên cùng
            Container(
              child: ImageHelper.loadFromAsset(
                AssetHelper.imageLogoSplashScreen,
                width: 180,
                height: 180,
                alignment: Alignment.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _userName,
              decoration: InputDecoration(
                labelText: 'Tên Đăng Nhập',
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorApp.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: const Color.fromARGB(255, 29, 92, 252), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorApp.primaryColor, width: 2.0),
                ),
                prefixIcon: Icon(
                  Icons.person_outline_outlined,
                  size: 28,
                  color: const Color.fromARGB(255, 29, 92, 252),
                ),
              ),
            ),
            SizedBox(height: 24),
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                TextField(
                  controller: _passWord,
                  obscureText: !_isShowPass,
                  decoration: InputDecoration(
                    labelText: 'Mật Khẩu',
                    labelStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
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
                      borderSide:
                          BorderSide(color: ColorApp.primaryColor, width: 2.0),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 28,
                      color: const Color.fromARGB(255, 29, 92, 252),
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
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: _onChanged,
                ),
                Text(
                  'Ghi Nhớ Đăng Nhập',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ButtonWidget(
              title: 'Đăng Nhập',
              ontap: () {
                // CustomDialogWidget.show(context);
                // _addData();
                Navigator.of(context).pushNamed(MainHomePage.routeName);
              },
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                'Quên mật khẩu ?',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 11, 155, 239),
                  decoration: TextDecoration.underline, // Thêm gạch dưới
                  decorationColor: Colors.blue, // Màu gạch dưới (tùy chọn)
                  decorationStyle:
                      TextDecorationStyle.solid, // Kiểu gạch dưới (tùy chọn)
                ),
              ),
            ),
            SizedBox(height: 50), // Thêm khoảng cách dưới cùng
          ],
        ),
      ),
    );
  }
}

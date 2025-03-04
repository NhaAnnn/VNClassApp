import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/login/controller/account_controller.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/main_home/views/main_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String routeName = 'login_page';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;
  bool _isShowPass = false;
  bool _isLoading = false;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AccountController _accountController = AccountController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedUsername = _prefs.getString('username');
    final savedPassword = _prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      _userNameController.text = savedUsername;
      _passwordController.text = savedPassword;
      setState(() => _isChecked = true);
      _autoLogin(savedUsername, savedPassword);
    }
  }

  void _onChanged(bool? newValue) =>
      setState(() => _isChecked = newValue ?? false);
  void _toggleShowPass() => setState(() => _isShowPass = !_isShowPass);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password.trim());
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _autoLogin(String username, String password) async {
    final passHash = _hashPassword(password);
    setState(() => _isLoading = true);
    try {
      AccountModel account =
          await _accountController.fetchAccount(username, passHash);
      await account.fetchGroupModel();
      Provider.of<AccountProvider>(context, listen: false).setAccount(account);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(MainHomePage.routeName);
      }
    } catch (e) {
      print('Auto-login failed: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    final String username = _userNameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Tên đăng nhập hoặc mật khẩu không được để trống');
      return;
    }

    final String passHash = _hashPassword(password);
    setState(() => _isLoading = true);
    print("passss: '$passHash'");
    print("user: '$username'");

    try {
      AccountModel account =
          await _accountController.fetchAccount(username, passHash);
      print('Account fetched: $account');
      await account.fetchGroupModel();
      print('Group model fetched successfully');

      if (_isChecked) {
        await _prefs.setString('username', username);
        await _prefs.setString('password', password);
        print('Credentials saved');
      } else {
        await _prefs.remove('username');
        await _prefs.remove('password');
        print('Credentials removed');
      }

      Provider.of<AccountProvider>(context, listen: false).setAccount(account);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(MainHomePage.routeName);
      }
    } catch (e) {
      print('Login failed: $e');
      if (e.toString().contains('PlatformException') &&
          e.toString().contains('shared_preferences')) {
        _showMessage('Lỗi lưu thông tin đăng nhập, vui lòng thử lại');
      } else {
        _showMessage('Tài khoản hoặc mật khẩu không đúng');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ImageHelper.loadFromAsset(
                      AssetHelper.imageLogoSplashScreen,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _userNameController,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    labelStyle:
                        TextStyle(fontSize: 16, color: Colors.blue.shade600),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: 24,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isShowPass,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle:
                        TextStyle(fontSize: 16, color: Colors.blue.shade600),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 24,
                      color: Colors.blue.shade600,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _toggleShowPass,
                      child: Icon(
                        _isShowPass
                            ? FontAwesomeIcons.eye
                            : FontAwesomeIcons.eyeSlash,
                        size: 20,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: _onChanged,
                      activeColor: Colors.blue.shade700,
                      checkColor: Colors.white,
                    ),
                    Text(
                      'Ghi nhớ đăng nhập',
                      style:
                          TextStyle(fontSize: 15, color: Colors.grey.shade800),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ButtonWidget(
                    title: 'Đăng nhập',
                    color: Colors.blue.shade700,
                    ontap: _login,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    // Add forgot password logic here if needed
                  },
                  child: Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

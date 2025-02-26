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
  bool _isLoading = false;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void onToggleShowPass() => setState(() => _isShowPass = !_isShowPass);
  void onToggleShowPassNew() =>
      setState(() => _isShowPassNew = !_isShowPassNew);
  void onToggleShowPassAgain() =>
      setState(() => _isShowPassAgain = !_isShowPassAgain);

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _changePassword() async {
    setState(() => _isLoading = true);

    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String hashedOldPassword = _hashPassword(oldPassword);

    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    final account = accountProvider.account;

    if (hashedOldPassword == account!.passWord) {
      if (newPassword == confirmPassword) {
        String hashedNewPassword = _hashPassword(newPassword);
        var snapshot = await FirebaseFirestore.instance
            .collection('ACCOUNT')
            .where('_id', isEqualTo: account.idAcc)
            .get();
        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference
              .update({'_pass': hashedNewPassword});
          CustomDialogWidget.showConfirmationDialog(
              context, 'Mật khẩu đã được cập nhật!');
          Future.delayed(
              const Duration(seconds: 2), () => Navigator.pop(context));
        } else {
          CustomDialogWidget.showConfirmationDialog(
              context, 'Không tìm thấy tài khoản!');
        }
      } else {
        CustomDialogWidget.showConfirmationDialog(
            context, 'Mật khẩu mới không khớp!');
      }
    } else {
      CustomDialogWidget.showConfirmationDialog(
          context, 'Mật khẩu cũ không đúng!');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Đổi mật khẩu',
      child: Container(
        color: Colors.grey.shade50, // Light, professional background
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: _oldPasswordController,
                    label: 'Mật khẩu cũ',
                    isVisible: _isShowPass,
                    onToggle: onToggleShowPass,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'Mật khẩu mới',
                    isVisible: _isShowPassNew,
                    onToggle: onToggleShowPassNew,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Nhập lại mật khẩu',
                    isVisible: _isShowPassAgain,
                    onToggle: onToggleShowPassAgain,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          title: 'Lưu thay đổi',
                          color: Colors.green.shade700, // Green for save
                          ontap: () {
                            CustomDialogWidget.showConfirmationDialog(
                              context,
                              'Xác nhận thay đổi mật khẩu?',
                              onTapOK: _changePassword,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ButtonWidget(
                          title: 'Thoát',
                          color: Colors.red.shade700,
                          ontap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade400, width: 2),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
            size: 20,
            color: Colors.blueGrey.shade400,
          ),
        ),
      ),
    );
  }
}

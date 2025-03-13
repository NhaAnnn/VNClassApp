import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/views/user_change_pass_screen.dart';

class UserScreenWeb extends StatelessWidget {
  const UserScreenWeb({super.key});
  static const String routeName = '/user_screen_web';

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCard(
                        title: 'Thông tin tài khoản',
                        children: [
                          _buildInfoRow('Tên tài khoản:', account!.userName),
                          _buildInfoRow('Họ và tên:', account.accName),
                          _buildInfoRow('Giới tính:', account.gender),
                          _buildInfoRow('Ngày sinh:', account.birth),
                          _buildInfoRow(
                              'Loại tài khoản:', account.groupModel!.groupName),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildCard(
                        title: 'Tùy chọn',
                        children: [
                          _buildMenuItem(context, 'Đổi mật khẩu', () {
                            showDialog(
                              context: context,
                              builder: (context) => _UserChangePassDialog(),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Row(
        children: [
          Icon(Icons.settings, size: 28, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 16),
          Text('Cài đặt',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A))),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Icon(
                FontAwesomeIcons.chevronRight,
                size: 16,
                color: Color(0xFF78909C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserChangePassDialog extends StatefulWidget {
  @override
  State<_UserChangePassDialog> createState() => _UserChangePassDialogState();
}

class _UserChangePassDialogState extends State<_UserChangePassDialog> {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mật khẩu đã được cập nhật!')),
          );
          Navigator.pop(context); // Đóng dialog sau khi thành công
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy tài khoản!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu mới không khớp!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu cũ không đúng!')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          title: 'Lưu thay đổi',
                          color: Colors.green.shade700,
                          ontap: () {
                            _changePassword();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ButtonWidget(
                          title: 'Hủy',
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

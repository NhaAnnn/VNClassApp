import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/view/login_page.dart';
import 'package:vnclass/modules/main_home/views/user_change_pass_screen.dart';
import 'package:vnclass/modules/main_home/views/user_change_type_mistake_screen.dart';
import 'package:vnclass/modules/main_home/views/user_set_points_screen.dart';
import '../../../common/helper/asset_helper.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;
    final theme = Theme.of(context);

    return AppBarWidget(
      titleString: 'Thông tin tài khoản',
      implementLeading: true,
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: ImageHelper.loadFromAsset(
                    AssetHelper.imageLogoSplashScreen,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Informations du compte
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Thông tin tài khoản',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF263238),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow('Họ và tên:', account!.accName),
                    _buildInfoRow('Tên tài khoản:', account.userName),
                    _buildInfoRow('Giới tính:', account.gender),
                    _buildInfoRow('Ngày sinh:', account.birth),
                    _buildInfoRow(
                        'Loại tài khoản:', account.groupModel!.groupName),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Options
              _buildMenuItem(context, 'Chính sách', null),
              _buildMenuItem(context, 'Tùy chỉnh vi phạm',
                  UserChangeTypeMistakeScreen.routeName),
              _buildMenuItem(
                  context, 'Đổi mật khẩu', UserChangePassScreen.routeName),
              _buildMenuItem(
                  context, 'Thiết lập mức điểm', UserSetPointsScreen.routeName),
              const SizedBox(height: 32),
              // Bouton
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Đăng xuất',
                  color: const Color(0xFFD32F2F),
                  ontap: () async {
                    // Lấy instance SharedPreferences
                    final prefs = await SharedPreferences.getInstance();

                    // Xóa thông tin đăng nhập đã lưu
                    await prefs.remove('username');
                    await prefs.remove('password');

                    // Xóa thông tin tài khoản trong AccountProvider
                    //   Provider.of<AccountProvider>(context, listen: false)
                    //    .clearAccount();

                    // Quay lại màn hình trước đó (hoặc chuyển đến LoginPage)
                    //  Navigator.pop(context);
                    // Nếu muốn chuyển thẳng đến LoginPage, thay bằng:
                    Navigator.pushReplacementNamed(
                        context, LoginPage.routeName);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF455A64),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String? routeName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GestureDetector(
        onTap: routeName != null
            ? () => Navigator.of(context).pushNamed(routeName)
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
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
                  color: Color(0xFF263238),
                ),
              ),
              if (routeName != null)
                Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: const Color(0xFF78909C),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

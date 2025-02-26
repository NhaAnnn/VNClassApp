import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/account/view/account_creat_acc_page.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/views/main_home_page.dart';
import 'package:vnclass/modules/main_home/views/user_change_pass_screen.dart';
import 'package:vnclass/modules/main_home/views/user_change_type_mistake_screen.dart';
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

    return AppBarWidget(
      titleString: 'Thông tin tài khoản',
      implementLeading: true,
      child: Container(
        color: Colors.grey.shade50, // Subtle, light background
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
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
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Thông tin tài khoản',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildClassRow('Họ và tên:', account!.accName),
                    _buildClassRow('Tên tài khoản:', account.userName),
                    _buildClassRow('Giới tính:', account.gender),
                    _buildClassRow('Ngày sinh:', account.birth),
                    _buildClassRow(
                        'Loại tài khoản:', account.groupModel!.groupName),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildItemDetail(context, 'Chính sách'),
              _buildItemDetail(context, 'Tùy chỉnh vi phạm',
                  routeName: UserChangeTypeMistakeScreen.routeName),
              _buildItemDetail(context, 'Đổi mật khẩu',
                  routeName: UserChangePassScreen.routeName),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  title: 'Đăng xuất',
                  color: Colors.red.shade700,
                  ontap: () {
                    Navigator.pop(context); // Add logout logic if needed
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(BuildContext context, String title,
      {String? routeName}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: routeName != null
            ? () => Navigator.of(context).pushNamed(routeName)
            : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (routeName != null)
                Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

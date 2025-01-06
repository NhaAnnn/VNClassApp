import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/account/view/account_creat_acc_page.dart';
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
    return AppBarWidget(
      titleString: 'Thông tin tài khoản',
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Căn giữa theo chiều dọc
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: ImageHelper.loadFromAsset(
                AssetHelper.imageLogoSplashScreen,
                width: 120,
                height: 120,
                alignment: Alignment.center,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(
                  color: Colors.black.withAlpha(50), // Border color
                  width: 2, // Border width
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Thông tin tài khoản',
                          style: TextStyle(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    _buildClassRow('Họ và tên:', 'Nguyễn trần châu hải đông'),
                    _buildClassRow('Tên tài khoản:', 'B21035615'),
                    _buildClassRow('Lớp:', '120a12'),
                    _buildClassRow('Giới tính', 'Nam'),
                    _buildClassRow('Ngày sinh:', '12/12/2025'),
                    _buildClassRow('Chức vụ:', 'Ban giám hiệu')
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            _buildItemDetail(context, 'Chinh sách'),
            _buildItemDetail(context, 'Tùy chỉnh vi phạm',
                routeName: UserChangeTypeMistakeScreen.routeName),
            _buildItemDetail(context, 'Đổi mật khẩu',
                routeName: UserChangePassScreen.routeName),
          ],
        ),
      ),
    );
  }

  Widget _buildClassRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetail<T>(BuildContext context, String title,
      {String? routeName}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(
            color: Colors.black.withAlpha(50), // Border color
            width: 2, // Border width
          ),
        ),
        child: GestureDetector(
          onTap: routeName != null
              ? () => Navigator.of(context).pushNamed(routeName)
              : null, // Không làm gì nếu routeName là null
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 16.0, horizontal: 8.0), // Thêm padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn giữa
              children: [
                Expanded(
                  flex: 8,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                // Chỉ hiển thị Icon nếu có routeName
                Expanded(
                  flex: 2,
                  child: Icon(
                    FontAwesomeIcons.arrowRight,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/app_bar_container.dart';
import 'package:vnclass/modules/account/view/account_main_page.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/login/widget/item_home.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/mistake/view/mistake_main_page.dart';
import 'package:vnclass/modules/report/view/report_main_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  // final AccountModel? account;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách năm học khi HomeScreen được khởi tạo
    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    yearProvider.fetchYears();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: AppBarContainer(
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                ClipRRect(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ImageHelper.loadFromAsset(
                      AssetHelper.imageLogoSplashScreen,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        account != null
                            ? 'Hello ${account.accName}'
                            : 'Hello User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      account!.groupModel?.groupName ?? 'No Group',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          implementLeading: true,
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ItemHome(
                      onTap: () => Navigator.of(context)
                          .pushNamed(MistakeMainPage.routeName),
                      icon: AssetHelper.iconMainHomeWrite,
                      title: 'Cập Nhật Vi Phạm'),
                  SizedBox(height: 20),
                  ItemHome(
                    icon: AssetHelper.iconMainHomeTaskView,
                    title: 'KQ Rèn Luyện',
                  ),
                  SizedBox(height: 20),
                  ItemHome(
                    icon: AssetHelper.iconMainHomeClass,
                    title: 'Lớp Học',
                  ),
                  SizedBox(height: 20),
                  ItemHome(
                    onTap: () => Navigator.of(context)
                        .pushNamed(ReportMainPage.routeName),
                    icon: AssetHelper.iconMainHomeReport,
                    title: 'Báo Cáo',
                  ),
                  SizedBox(height: 20),
                  ItemHome(
                    onTap: () => Navigator.of(context)
                        .pushNamed(AccountMainPage.routeName),
                    icon: AssetHelper.iconMainHomeAccount,
                    title: 'Quản Lý Tài Khoản',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/common/widget/app_bar_container.dart';
import 'package:vnclass/modules/account/view/account_main_page.dart';
import 'package:vnclass/modules/login/widget/item_home.dart';
import 'package:vnclass/modules/mistake/view/mistake_main_page.dart';
import 'package:vnclass/modules/report/view/report_main_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
                      borderRadius: BorderRadius.circular(
                        24,
                      ),
                    ),
                    child: ImageHelper.loadFromAsset(
                        AssetHelper.imageLogoSplashScreen),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hello Suong nguyễn trần châu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Position',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                // Spacer(),
                // Icon(
                //   FontAwesomeIcons.bell,
                //   size: 24,
                //   color: Colors.black,
                // ),
              ],
            ),
          ),
          implementLeading: true,
          child: Container(
            //margin: EdgeInsets.only(top: 20),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // TextField(
                  //   decoration: InputDecoration(
                  //     hintText: 'hl',
                  //     prefixIcon: Padding(
                  //       padding: EdgeInsets.all(12),
                  //       child: Icon(
                  //         FontAwesomeIcons.magnifyingGlass,
                  //         color: Colors.black,
                  //         size: 16,
                  //       ),
                  //     ),
                  //     filled: true,
                  //     fillColor: Colors.amberAccent,
                  //     border: OutlineInputBorder(
                  //       borderSide: BorderSide.none,
                  //       borderRadius: BorderRadius.all(
                  //         Radius.circular(
                  //           4,
                  //         ),
                  //       ),
                  //     ),
                  //     contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  ItemHome(
                      onTap: () => Navigator.of(context)
                          .pushNamed(MistakeMainPage.routeName),
                      icon: AssetHelper.iconMainHomeWrite,
                      title: 'Cập Nhật Vi Phạm'),
                  SizedBox(
                    height: 20,
                  ),
                  ItemHome(
                    icon: AssetHelper.iconMainHomeTaskView,
                    title: 'KQ Rèn Luyện',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ItemHome(
                    icon: AssetHelper.iconMainHomeClass,
                    title: 'Lớp Học',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ItemHome(
                    onTap: () => Navigator.of(context)
                        .pushNamed(ReportMainPage.routeName),
                    icon: AssetHelper.iconMainHomeReport,
                    title: 'Báo Cáo',
                  ),
                  SizedBox(
                    height: 20,
                  ),
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

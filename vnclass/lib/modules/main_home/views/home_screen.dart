import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/modules/account/view/account_main_page.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/login/model/account_model.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/mistake/view/mistake_main_page.dart';
import 'package:vnclass/modules/report/view/report_main_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    yearProvider.fetchYears();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Stack(
        children: [
          // Background Image Area with White Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              color: Colors.white, // White background for image
              child: Stack(
                children: [
                  Center(
                    child: ImageHelper.loadFromAsset(
                      AssetHelper.imageLogoSplashScreen,
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Notification Bell Icon
                  Positioned(
                    top: 40,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Chức năng thông báo đang phát triển')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          FontAwesomeIcons.bell,
                          size: 24,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content with Bolder Divider and Softer Shadow
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, -4),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(
                        color: Colors.blue.shade300,
                        width: 2,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                account != null
                                    ? 'Xin chào, ${account.accName}'
                                    : 'Xin chào',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          account?.groupModel?.groupName ?? 'Chưa có nhóm',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildHomeItem(
                          context,
                          icon: FontAwesomeIcons.penToSquare,
                          title: 'Cập Nhật Vi Phạm',
                          route: MistakeMainPage.routeName,
                        ),
                        const SizedBox(height: 16),
                        _buildHomeItem(
                          context,
                          icon: FontAwesomeIcons.chartLine,
                          title: 'KQ Rèn Luyện',
                        ),
                        const SizedBox(height: 16),
                        _buildHomeItem(
                          context,
                          icon: FontAwesomeIcons.school,
                          title: 'Lớp Học',
                        ),
                        const SizedBox(height: 16),
                        _buildHomeItem(
                          context,
                          icon: FontAwesomeIcons.fileLines,
                          title: 'Báo Cáo',
                          route: ReportMainPage.routeName,
                        ),
                        const SizedBox(height: 16),
                        _buildHomeItem(
                          context,
                          icon: FontAwesomeIcons.userGear,
                          title: 'Quản Lý Tài Khoản',
                          route: AccountMainPage.routeName,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeItem(BuildContext context,
      {required IconData icon, required String title, String? route}) {
    return GestureDetector(
      onTap:
          route != null ? () => Navigator.of(context).pushNamed(route) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.blue.shade500,
            width: 1.95,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade50.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            if (route != null)
              Icon(
                Icons.chevron_right,
                size: 24,
                color: Colors.blue.shade600,
              ),
          ],
        ),
      ),
    );
  }
}

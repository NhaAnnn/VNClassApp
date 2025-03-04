import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/modules/account/view/account_main_page.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/class_provider.dart';
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
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    classProvider.fetchClassNames();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Phần nền trên cùng với gradient và ảnh tròn
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF42A5F5), // Xanh dương nhạt
                    Color(0xFF1976D2), // Xanh dương đậm
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ClipOval(
                      child: ImageHelper.loadFromAsset(
                        AssetHelper.imageLogoSplashScreen,
                        width: 120, // Giảm kích thước để cân đối
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Chức năng thông báo đang phát triển'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          FontAwesomeIcons.bell,
                          size: 24,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Phần nội dung chính
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.22),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 12,
                        spreadRadius: -2,
                        offset: const Offset(0, -6),
                      ),
                    ],
                    border: Border(
                      top: BorderSide(
                        color: Colors.blue.shade200,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 28),
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
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF263238),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          account?.groupModel?.groupName ?? 'Chưa có nhóm',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap:
          route != null ? () => Navigator.of(context).pushNamed(route) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.blue.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade50.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32, // Giảm kích thước icon để cân đối
              color: const Color(0xFF1976D2),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF263238),
                ),
              ),
            ),
            if (route != null)
              Icon(
                Icons.chevron_right,
                size: 24,
                color: Colors.blue.shade400,
              ),
          ],
        ),
      ),
    );
  }
}

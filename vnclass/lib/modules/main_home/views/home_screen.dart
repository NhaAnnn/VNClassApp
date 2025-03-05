import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/modules/account/view/account_main_page.dart';
import 'package:vnclass/modules/classes/view/all_classes.dart';
import 'package:vnclass/modules/conduct/view/all_conduct.dart';
import 'package:vnclass/modules/conduct/widget/choose_year_dialog.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/class_provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/mistake/view/mistake_main_page.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_change.dart';
import 'package:vnclass/modules/notification/model/notification_model.dart';
import 'package:vnclass/modules/notification/view/notification_screen.dart';
import 'package:vnclass/modules/report/view/report_main_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    yearProvider.fetchYears();
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    classProvider.fetchClassNames();
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    accountProvider.account;

    fetchNotifications(accountProvider.account!.idAcc, context);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleIncomingNotification(message);
    });
  }

  void handleIncomingNotification(RemoteMessage message) {
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    NotificationModel newNotification = NotificationModel(
      id: message.messageId ?? DateTime.now().toString(),
      accountId: accountProvider.account!.idAcc,
      notificationTitle: message.notification?.title ?? 'Thông báo mới',
      notificationDetail: message.notification?.body ?? 'Nội dung thông báo',
      isRead: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      notifications.add(newNotification);
      Provider.of<NotificationChange>(context, listen: false)
          .incrementUnreadCount();
    });
  }

  Future<void> fetchNotifications(
      String accountId, BuildContext context) async {
    notifications = await NotificationController.fetchNotifications(accountId);
    int unreadCount = notifications.where((n) => !n.isRead).length;
    Provider.of<NotificationChange>(context, listen: false)
        .setUnreadCount(unreadCount);
    print('Số thông báo chưa đọc: $unreadCount'); // Debug
    setState(() {}); // Cập nhật giao diện
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
                    Color(0xFF42A5F5),
                    Color(0xFF1976D2),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ClipOval(
                      child: ImageHelper.loadFromAsset(
                        AssetHelper.imageLogoSplashScreen,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: Stack(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 40,
                          ),
                          if (Provider.of<NotificationChange>(context)
                                  .unreadCount >
                              0) // Chỉ hiển thị nếu có thông báo chưa đọc
                            Positioned(
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  '${Provider.of<NotificationChange>(context).unreadCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          NotificationScreen.routeName,
                          arguments: {
                            'notifications': notifications,
                            'onUpdate': () {
                              setState(() {});
                            },
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                          dialog: 'Dialog',
                        ),
                        const SizedBox(height: 16),
                        _buildHomeItem(
                          context,
                          icon: FontAwesomeIcons.school,
                          title: 'Lớp Học',
                          route: AllClasses.routeName,
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
      {required IconData icon,
      required String title,
      String? route,
      String? dialog}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.of(context).pushNamed(route);
        }
        if (dialog != null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ChooseYearDialog();
            },
          );
        }
      },
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
              size: 32,
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
            if (route != null || dialog != null)
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

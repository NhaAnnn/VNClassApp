import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnclass/common/helper/asset_helper.dart';
import 'package:vnclass/common/helper/image_helper.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/class_provider.dart';
import 'package:vnclass/modules/main_home/controller/permission_provider.dart';
import 'package:vnclass/modules/main_home/controller/student_detail_provider.dart';
import 'package:vnclass/modules/main_home/controller/teacher_provider.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:vnclass/modules/notification/controller/notification_controller.dart';
import 'package:vnclass/modules/notification/funtion/notification_change.dart';
import 'package:vnclass/modules/notification/model/notification_model.dart';
import 'package:vnclass/modules/notification/view/notification_screen.dart';
import 'package:vnclass/web/account/account_main_page_web.dart';
import 'package:vnclass/web/login/login_web_page.dart';
import 'package:vnclass/web/mistake/mistake_main_page_web.dart';
import 'package:vnclass/web/set_up_mistake/user_change_type_mistake_screen_web.dart';
import 'package:vnclass/web/set_up_point/user_set_points_screen_web.dart';
import 'package:vnclass/web/setting/user_screen_web.dart';

class MainHomeWebPage extends StatefulWidget {
  const MainHomeWebPage({super.key});
  static String routeName = 'main_home_web_page';

  @override
  State<MainHomeWebPage> createState() => _MainHomeWebPageState();
}

class _MainHomeWebPageState extends State<MainHomeWebPage> {
  List<NotificationModel> notifications = [];
  String _selectedRoute = '/dashboard';
  bool _isLoading = true;

  // Dữ liệu giả lập cho dashboard
  final Map<String, int> attendanceStats = {
    'Jan': 50000,
    'Feb': 60000,
    'Mar': 55000,
    'Apr': 52000,
    'Aug': 58000,
    'Sep': 59000,
    'Nov': 54000,
    'Dec': 53000,
  };

  final Map<String, double> recruitmentSource = {
    'Direct': 0.80,
    'Google': 0.15,
    'Refer': 0.05,
  };

  final List<Map<String, dynamic>> leaveApplications = [
    {'name': 'Dawash King', 'date': '29-03-2024', 'status': 'Approved'},
    {'name': 'Musad Rana', 'date': '29-03-2024', 'status': 'Approved'},
    {'name': 'Jalil Hossain', 'date': '29-03-2024', 'status': 'Pending'},
  ];

  final List<Map<String, dynamic>> notices = [
    {'title': 'Get ready for meeting at 6', 'date': '29-03-2024'},
    {'title': 'Dashboard updated', 'date': '29-03-2024'},
  ];

  final List<Map<String, dynamic>> recruitment = [
    {'name': 'Noman Khan', 'status': 'Recruited'},
    {'name': 'Aslam Islam', 'status': 'Recruited'},
    {'name': 'Musad Rana', 'status': 'Recruited'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSelectedRoute();
    await Provider.of<AccountProvider>(context, listen: false)
        .loadAccountFromPrefs();
    await _initializeData();
  }

  Future<void> _loadSelectedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRoute = prefs.getString('selectedRoute') ??
          '/dashboard'; // Mặc định là dashboard
    });
  }

  Future<void> _saveSelectedRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoute', route);
  }

  Future<void> _initializeData() async {
    try {
      final yearProvider = Provider.of<YearProvider>(context, listen: false);
      await yearProvider.fetchYears();

      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      await classProvider.fetchClassNames();

      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      if (accountProvider.account!.goupID == 'giaoVien') {
        final teacherProvider =
            Provider.of<TeacherProvider>(context, listen: false);
        teacherProvider.fetchClassIDTeacher(accountProvider.account!.idAcc);
      } else if (accountProvider.account!.goupID == 'hocSinh') {
        final studentDetailProvider =
            Provider.of<StudentDetailProvider>(context, listen: false);
        studentDetailProvider
            .fetchStudentDetail(accountProvider.account!.idAcc);
      }
      if (accountProvider.account != null) {
        await fetchNotifications(accountProvider.account!.idAcc, context);

        List<String> groupPermissions = [];
        List<String> accountPermissions =
            List.from(accountProvider.account!.permission);

        accountProvider.account!.groupModel?.permission.forEach((key, value) {
          if (value.length > 1) groupPermissions.add(value[1]);
        });

        List<String> pers = [];
        pers.addAll(accountPermissions);
        pers.addAll(groupPermissions);

        final permissProvider =
            Provider.of<PermissionProvider>(context, listen: false);
        permissProvider.setPermission(pers);

        final classIdProvider =
            Provider.of<StudentDetailProvider>(context, listen: false);
        await classIdProvider
            .fetchStudentDetail(accountProvider.account!.idAcc);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginWebPage.routeName);
      }
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchNotifications(
      String accountId, BuildContext context) async {
    if (accountId.isEmpty) return;
    notifications = await NotificationController.fetchNotifications(accountId);
    int unreadCount = notifications.where((n) => !n.isRead).length;
    Provider.of<NotificationChange>(context, listen: false)
        .setUnreadCount(unreadCount);
  }

  Widget _buildPageContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final yearProvider = Provider.of<YearProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    if (yearProvider.years.isEmpty || classProvider.classNames.isEmpty) {
      return const Center(
          child: Text('Dữ liệu chưa sẵn sàng, vui lòng thử lại sau'));
    }

    switch (_selectedRoute) {
      case '/dashboard':
        return _buildHomePage();
      case MistakeMainPageWeb.routeName:
        return const MistakeMainPageWeb();
      case '/update_violation':
        return const MistakeMainPageWeb();
      case '/settings':
        return const UserScreenWeb();
      case '/mistake_settings':
        return const UserChangeTypeMistakeScreenWeb();
      case '/score_settings':
        return const UserSetPointsScreenWeb();
      case '/account_management':
        return const AccountMainPageWeb();
      case '/logout':
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text(
                    'Đăng Xuất',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await Provider.of<AccountProvider>(context, listen: false)
                          .clearAccount();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginWebPage.routeName,
                          (Route<dynamic> route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          Colors.redAccent, // Đảm bảo chữ hiển thị màu trắng
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Đăng xuất',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      default:
        return _buildHomePage(); // Mặc định quay về dashboard nếu route không hợp lệ
    }
  }

  Widget _buildHomePage() {
    return _buildPage('Dashboard', Icons.dashboard, [
      // Thống kê
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('Total Employee', '26', '+1%'),
          _buildStatCard('Total Absent', '16', '-1%'),
          _buildStatCard('Today Present', '2', '+1%'),
          _buildStatCard('Total Leave', '26', '+1%'),
        ],
      ),
      const SizedBox(height: 24),
      // Biểu đồ cột
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This Daily Attendance Statistic',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A))),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: attendanceStats.entries.map((entry) {
                  return Expanded(
                    child: Column(
                      children: [
                        Text(entry.key,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700)),
                        const SizedBox(height: 8),
                        Container(
                          height: 150 * (entry.value / 60000),
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.blue[700],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text('${entry.value ~/ 1000}k',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      // Biểu đồ tròn
      Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 1)
                ],
              ),
              child: Column(
                children: [
                  const Text('Loan Payment Received',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.8,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.blue[700],
                          strokeWidth: 20,
                        ),
                        const Text('80%',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: recruitmentSource.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: e.key == 'Direct'
                                        ? Colors.blue[700]
                                        : e.key == 'Google'
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${e.key}: ${e.value * 100}%',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade800)),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      // Đơn xin nghỉ phép và thông báo
      Row(
        children: [
          Expanded(
            child: _buildSection('Leave Application', [
              for (var app in leaveApplications)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[700],
                    radius: 20,
                    child: Text(app['name'][0],
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(app['name'],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(app['date'],
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  trailing: Text(app['status'],
                      style: TextStyle(
                          fontSize: 12,
                          color: app['status'] == 'Approved'
                              ? Colors.green
                              : Colors.orange)),
                ),
            ]),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: _buildSection('Notice', [
              for (var noti in notices)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(noti['title'],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(noti['date'],
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ),
            ]),
          ),
        ],
      ),
      const SizedBox(height: 24),
      // Tuyển dụng
      _buildSection('Recruitment', [
        for (var rec in recruitment)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.blue[700],
              radius: 20,
              child: Text(rec['name'][0],
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(rec['name'],
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            trailing: Text(rec['status'],
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500)),
          ),
      ]),
    ]);
  }

  Widget _buildPage(String title, IconData icon, List<Widget> content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF1E3A8A)),
              const SizedBox(width: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A))),
            ],
          ),
          const SizedBox(height: 24),
          ...content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn đang ở trang chính, không thể quay lại.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Row(
          children: [
            // Sidebar
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF1F2A44),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 0)),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        child: ImageHelper.loadFromAsset(
                          AssetHelper.imageLogoSplashScreen,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildSidebarItem(
                            Icons.dashboard, 'Dashboard', '/dashboard',
                            isSelected: _selectedRoute == '/dashboard'),
                        _buildSidebarItem(Icons.warning, 'Cập nhật vi phạm',
                            '/update_violation',
                            isSelected: _selectedRoute == '/update_violation'),
                        _buildSidebarItem(Icons.bar_chart, 'Kết quả rèn luyện',
                            '/training_result',
                            isSelected: _selectedRoute == '/training_result'),
                        _buildSidebarItem(Icons.person, 'Quản lý tài khoản',
                            '/account_management',
                            isSelected:
                                _selectedRoute == '/account_management'),
                        _buildSidebarItem(
                            Icons.tune, 'Thiết lập mức điểm', '/score_settings',
                            isSelected: _selectedRoute == '/score_settings'),
                        _buildSidebarItem(
                            Icons.tune,
                            'Thiết lập vi phạm và loại vi phạm',
                            '/mistake_settings',
                            isSelected: _selectedRoute == '/mistake_settings'),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      _buildSidebarItem(Icons.settings, 'Cài đặt', '/settings',
                          isSelected: _selectedRoute == '/settings'),
                      _buildSidebarItem(Icons.logout, 'Đăng Xuất', '/logout',
                          isSelected: _selectedRoute == '/logout'),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E3A8A).withOpacity(0.9),
                          const Color(0xFF3B82F6).withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            ImageHelper.loadFromAsset(
                                AssetHelper.imageLogoSplashScreen,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover),
                            const SizedBox(width: 12),
                            const Text(
                              'VNClass',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Stack(
                            children: [
                              const Icon(Icons.notifications,
                                  color: Colors.white, size: 28),
                              if (Provider.of<NotificationChange>(context)
                                      .unreadCount >
                                  0)
                                Positioned(
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6)),
                                    constraints: const BoxConstraints(
                                        minWidth: 12, minHeight: 12),
                                    child: Text(
                                      '${Provider.of<NotificationChange>(context).unreadCount}',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedRoute = NotificationScreen.routeName;
                              _saveSelectedRoute(_selectedRoute);
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: Text(
                                account?.accName.isNotEmpty == true
                                    ? account!.accName[0]
                                    : 'U',
                                style:
                                    const TextStyle(color: Color(0xFF1E3A8A)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(account?.accName ?? 'User',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white)),
                                Text(
                                    account?.groupModel?.groupName ??
                                        'Chưa có nhóm',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildPageContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, String route,
      {bool isSelected = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRoute = route;
            _saveSelectedRoute(route);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: isSelected ? const Color(0xFF2D3B53) : Colors.transparent,
          child: Row(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String change) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A))),
          Text(change,
              style: TextStyle(
                  fontSize: 12,
                  color: change.contains('+')
                      ? Colors.green[700]
                      : Colors.red[700])),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A))),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

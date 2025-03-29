import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:vnclass/modules/main_home/views/help_screen.dart';
import 'package:vnclass/modules/main_home/views/home_screen.dart';
import 'package:vnclass/modules/main_home/views/user_screen.dart';
import 'package:vnclass/modules/notification/widget/notification_dialog.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  static String routeName = 'main_home_page';

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    // Check for notification permissions on app start
    checkNotificationPermission(context);
  }

  Future<void> checkNotificationPermission(BuildContext context) async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      notificationDialog(context);
    } else if (status.isPermanentlyDenied) {
      notificationDialog(context);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match HomeScreen’s white background
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          HelpScreen(),
          UserScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: Colors.blue.shade700, // Sky-blue primary color
          unselectedItemColor:
              Colors.blue.shade300.withOpacity(0.7), // Softer blue
          itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          items: [
            SalomonBottomBarItem(
              icon: const Icon(FontAwesomeIcons.house, size: 24),
              title: const Text('Home',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              selectedColor: Colors.blue.shade700,
            ),
            SalomonBottomBarItem(
              icon: const Icon(FontAwesomeIcons.circleQuestion, size: 24),
              title: const Text('Help',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              selectedColor: Colors.blue.shade700,
            ),
            SalomonBottomBarItem(
              icon: const Icon(FontAwesomeIcons.user, size: 24),
              title: const Text('User',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              selectedColor: Colors.blue.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

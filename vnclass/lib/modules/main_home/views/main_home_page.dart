import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/modules/main_home/views/help_screen.dart';
import 'package:vnclass/modules/main_home/views/home_screen.dart';
import 'package:vnclass/modules/main_home/views/user_screen.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  static String routeName = 'main_home_page';

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(253, 255, 255, 255),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(),
          HelpScreen(),
          UserScreen(),
        ],
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: ColorApp.primaryColor,
        unselectedItemColor: ColorApp.primaryColor.withAlpha(200),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        items: [
          SalomonBottomBarItem(
            icon: Icon(
              FontAwesomeIcons.house,
              size: 28,
            ),
            title: Text(
              'Home',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          SalomonBottomBarItem(
            icon: Icon(
              FontAwesomeIcons.circleQuestion,
              size: 28,
            ),
            title: Text(
              'Help',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          SalomonBottomBarItem(
            icon: Icon(
              FontAwesomeIcons.user,
              size: 28,
            ),
            title: Text(
              'User',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

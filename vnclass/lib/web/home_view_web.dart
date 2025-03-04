import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vnclass/web/class_view_web.dart';

class HomeViewWeb extends StatefulWidget {
  const HomeViewWeb({super.key});
  static String routeName = 'home_view_web';

  @override
  _HomeViewWebState createState() => _HomeViewWebState();
}

class _HomeViewWebState extends State<HomeViewWeb> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@@@'),
      ),
      body: Row(children: [
        // Menu bên trái
        NavigationRail(
          backgroundColor: Colors.blueGrey,
          extended: true, // Mở rộng NavigationRail
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: <NavigationRailDestination>[
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text('Trang Chủ', style: TextStyle(fontSize: 14)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.school),
              label: Text('Quản Lý Lớp', style: TextStyle(fontSize: 14)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person),
              label: Text('Học Sinh', style: TextStyle(fontSize: 14)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings),
              label: Text('Cài Đặt', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        // Nội dung chính
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(selectedIndex),
          ),
        ),
      ]),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent(); // Content for Trang Chủ
      case 1:
        return ClassViewWeb(); // Content for Quản Lý Lớp
      case 2:
        return _buildStudentManagementContent(); // Content for Học Sinh
      case 3:
        return _buildSettingsContent(); // Content for Cài Đặt
      default:
        return _buildHomeContent(); // Fallback to home content
    }
  }

  Widget _buildHomeContent() {
    return Center(child: Text('Welcome to the Home Page!'));
  }

  Widget _buildStudentManagementContent() {
    return Center(child: Text('Student Management Content'));
  }

  Widget _buildSettingsContent() {
    return Center(child: Text('Settings Content'));
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vnclass/web/classes/class_view_web.dart';

class HomeViewWeb extends StatefulWidget {
  const HomeViewWeb({super.key});
  static String routeName = 'home_view_web';

  @override
  _HomeViewWebState createState() => _HomeViewWebState();
}

class _HomeViewWebState extends State<HomeViewWeb> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex(); // Load the saved index
  }

  Future<void> _loadSelectedIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedIndex =
          prefs.getInt('selectedIndex') ?? 0; // Default to 0 if not set
    });
  }

  Future<void> _saveSelectedIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedIndex', index); // Save the index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@@@'),
      ),
      body: Row(children: [
        NavigationRail(
          backgroundColor: Colors.blueGrey,
          extended: true,
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
              _saveSelectedIndex(index); // Save the selected index
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
        return _buildHomeContent();
      case 1:
        return ClassViewWeb();
      case 2:
        return _buildHomeContent();
      case 3:
        return _buildSettingsContent();
      default:
        return _buildHomeContent();
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

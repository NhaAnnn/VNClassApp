import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/account/widget/item_tabar_creat_acc.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/web/sidebar_widget.dart';

class AccountCreateAccPageWeb extends StatefulWidget {
  const AccountCreateAccPageWeb({super.key});
  static const String routeName = '/account_creat_acc_page_web';

  @override
  State<AccountCreateAccPageWeb> createState() =>
      _AccountCreateAccPageWebState();
}

class _AccountCreateAccPageWebState extends State<AccountCreateAccPageWeb> {
  void _navigateBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  final Map<String, dynamic> menuItem = {
    'icon': Icons.person_add,
    'label': 'Tạo tài khoản',
  };
  final bool _isSelected = true; // Mục được chọn sẵn
  void _onItemTapped() {
    // Không làm gì vì chỉ có 1 mục và đã chọn sẵn
    //  print('Đã nhấn: ${menuItem['label']}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9FAFB), 
      body: Row(
        children: [
// Sidebar
          SidebarWidget(
            appTitle: 'VNClass',
            menuItem: menuItem,
            isSelected: _isSelected,
            onItemTap: _onItemTapped,
          ),
          // Nội dung chính
          Expanded(
            child: Column(
              children: [
               
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _navigateBack,
                      ),
                      Expanded(
                        child: Text(
                          'Tạo tài khoản',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // TabBar và TabBarView
                Expanded(
                  child: DefaultTabController(
                    length: 3, // Số lượng tab
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          color: Colors.white,
                          child: TabBar(
                            tabs: const [
                              Tab(text: 'Ban giám hiệu'),
                              Tab(text: 'Giáo viên'),
                              Tab(text: 'Học sinh - Phụ huynh'),
                            ],
                            indicatorColor: const Color(0xFF1E90FF),
                            labelColor: const Color(0xFF1E3A8A),
                            unselectedLabelColor: Colors.grey.shade600,
                            labelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: ItemTabarCreatAcc(
                                  show: false,
                                  typeAcc: 'Ban giám hiệu',
                                ),
                              ),
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: ItemTabarCreatAcc(
                                  show: true,
                                  typeAcc: 'Giáo viên',
                                ),
                              ),
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: ItemTabarCreatAcc(
                                  show: true,
                                  typeAcc: 'Học sinh',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

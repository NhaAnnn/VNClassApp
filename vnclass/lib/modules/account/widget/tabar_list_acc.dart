import 'package:flutter/material.dart';
import 'package:vnclass/modules/account/widget/item_tabar_list_acc.dart';

class TabarListAcc extends StatefulWidget {
  const TabarListAcc({super.key});

  @override
  State<TabarListAcc> createState() => _TabarListAccState();
}

class _TabarListAccState extends State<TabarListAcc> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Bo góc cho Dialog
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Tiêu đề tùy chỉnh
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color:
                    Color(0xFF1976D2), // Màu xanh đậm nhã nhặn hơn blueAccent
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Text(
                  'Tạo nhiều tài khoản',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Giữ trắng cho tiêu đề
                  ),
                ),
              ),
            ),
            // TabBar
            Container(
              color: const Color(0xFF1976D2), // Xanh nhạt hơn cho TabBar
              child: TabBar(
                tabs: const [
                  Tab(text: 'Ban giám hiệu'),
                  Tab(text: 'Giáo viên'),
                  Tab(text: 'Học sinh'),
                ],
                indicator: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 3.0,
                      color: Colors.white, // Giữ trắng cho indicator
                    ),
                  ),
                ),
                labelColor: Colors.white, // Chữ tab được chọn là trắng
                unselectedLabelColor: Colors.white
                    .withOpacity(0.9), // Chữ không chọn nhạt hơn chút
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            // TabBarView
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: TabBarView(
                  children: [
                    ItemTabarListAcc(
                      title: 'Tải lên DS Tạo Tài Khoản BGH',
                      typeAcc: 'bgh',
                    ),
                    ItemTabarListAcc(
                      title: 'Tải lên DS Tạo Tài Khoản Giáo viên',
                      typeAcc: 'gv',
                    ),
                    ItemTabarListAcc(
                      title: 'Tải lên DS Tạo Tài Khoản Học sinh',
                      typeAcc: 'hs',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

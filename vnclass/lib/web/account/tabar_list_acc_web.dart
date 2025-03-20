import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Thêm kIsWeb
import 'package:vnclass/web/account/item_tabar_list_acc_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/item_tabar_list_acc_web.dart';

class TabarListAccWeb extends StatefulWidget {
  const TabarListAccWeb({super.key});

  @override
  State<TabarListAccWeb> createState() => _TabarListAccWebState();
}

class _TabarListAccWebState extends State<TabarListAccWeb> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1976D2),
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
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              color: const Color(0xFF1976D2),
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
                      color: Colors.white,
                    ),
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.9),
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: kIsWeb
                    ? TabBarView(
                        children: [
                          ItemTabarListAccWeb(
                            title: 'Tải lên DS Tạo Tài Khoản BGH',
                            typeAcc: 'bgh',
                          ),
                          ItemTabarListAccWeb(
                            title: 'Tải lên DS Tạo Tài Khoản Giáo viên',
                            typeAcc: 'gv',
                          ),
                          ItemTabarListAccWeb(
                            title: 'Tải lên DS Tạo Tài Khoản Học sinh',
                            typeAcc: 'hs',
                          ),
                        ],
                      )
                    : const Center(
                        child: Text('Chức năng này chỉ khả dụng trên web'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

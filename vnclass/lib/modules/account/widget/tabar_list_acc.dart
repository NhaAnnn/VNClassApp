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
      length: 3, // Number of tabs
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Ban giám hiệu'),
              Tab(text: 'Giáo viên'),
              Tab(text: 'Học sinh'),
            ],
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                ItemTabarListAcc(
                  title: 'Tải lên DS Tạo Tài Khoản BGH',
                ),
                ItemTabarListAcc(
                  title: 'Tải lên DS Tạo Tài Khoản Giáo viên',
                ),
                ItemTabarListAcc(
                  title: 'Tải lên DS Tạo Tài Khoản Học sinh',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

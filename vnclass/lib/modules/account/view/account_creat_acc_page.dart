import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/account/widget/item_tabar_creat_acc.dart';

class AccountCreatAccPage extends StatefulWidget {
  const AccountCreatAccPage({super.key});
  static const String routeName = '/account_creat_acc_page';

  @override
  State<AccountCreatAccPage> createState() => _AccountCreatAccPageState();
}

class _AccountCreatAccPageState extends State<AccountCreatAccPage> {
  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Tạo tài khoản',
      implementLeading: true,
      child: DefaultTabController(
        length: 3, // Số lượng tab
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Ban giám hiệu'),
                Tab(text: 'Giáo viên'),
                Tab(text: 'Học sinh - Phụ huynh'),
              ],
              indicatorColor: Theme.of(context).primaryColor,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: ItemTabarCreatAcc(
                      show: false,
                      typeAcc: 'Ban giám hiệu',
                    ),
                  ),
                  SingleChildScrollView(
                    child: ItemTabarCreatAcc(
                      show: true,
                      typeAcc: 'Giáo viên',
                    ),
                  ),
                  SingleChildScrollView(
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
    );
  }
}

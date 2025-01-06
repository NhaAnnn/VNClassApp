import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/account/model/account_model.dart';
import 'package:vnclass/modules/account/view/account_creat_acc_page.dart';
import 'package:vnclass/modules/account/widget/dialog_export_acc.dart';
import 'package:vnclass/modules/account/widget/item_account.dart';
import 'package:vnclass/modules/account/widget/tabar_list_acc.dart';

class AccountMainPage extends StatefulWidget {
  const AccountMainPage({super.key});
  static const String routeName = 'account_main_page';

  @override
  State<AccountMainPage> createState() => _AccountMainPageState();
}

class _AccountMainPageState extends State<AccountMainPage> {
  late Future<List<AccountModel>> futureMistakeClass;

  @override
  void initState() {
    super.initState();
    futureMistakeClass =
        fetchMistakeClasses(); // Gọi hàm lấy dữ liệu từ Firestore
  }

  Future<List<AccountModel>> fetchMistakeClasses() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => AccountModel.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Quản lý tài khoản',
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonWidget(
                title: 'Tạo nhiều tài khoản',
                ontap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height *
                              0.5, // Set a fixed height or use MediaQuery to make it responsive
                          child: TabarListAcc(),
                        ),
                      );
                    },
                  );
                },
              ),
              ButtonWidget(
                title: 'Tạo 1 tài khoản',
                ontap: () => Navigator.of(context)
                    .pushNamed(AccountCreatAccPage.routeName),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              ButtonWidget(
                title: 'Xuất DS tài khoản',
                ontap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DialogExportAcc();
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextField(
            style: TextStyle(
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  Icons.search_outlined,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              filled: true,
              fillColor: Colors.white,

              // Thêm viền bên ngoài
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue, // Màu viền
                  width: 2.0, // Độ dày viền
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueAccent, // Màu viền khi focus
                  width: 2.0, // Độ dày viền
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ), // Thêm khoảng cách giữa Row và TabBar
          Expanded(
            child: DefaultTabController(
              length: 3, // Số lượng tab
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Tab 1'),
                      Tab(text: 'Tab 2'),
                      Tab(text: 'Tab 3'),
                    ],
                    indicatorColor: Theme.of(context).primaryColor,
                  ),
                  Expanded(
                    flex: 9,
                    child: SizedBox(
                      //height: 200, // Chiều cao của nội dung Tab
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            child: Center(
                              child: FutureBuilder<List<AccountModel>>(
                                future: futureMistakeClass,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // Hiển thị loading
                                  }
                                  if (snapshot.hasError) {
                                    return Text(
                                        'Có lỗi xảy ra: ${snapshot.error}');
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Text('Không có dữ liệu');
                                  }

                                  // Hiển thị danh sách các lỗi
                                  return Column(
                                    children: snapshot.data!
                                        .map(
                                            (e) => ItemAccount(accountModel: e))
                                        .toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                          Center(child: Text('Nội dung Tab 2')),
                          Center(child: Text('Nội dung Tab 3')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

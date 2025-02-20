import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/account/controller/account_repository.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
import 'package:vnclass/modules/account/view/account_creat_acc_page.dart';
import 'package:vnclass/modules/account/widget/dialog_export_acc.dart';
import 'package:vnclass/modules/account/widget/item_account.dart';
import 'package:vnclass/modules/account/widget/tabar_list_acc.dart';
import 'package:vnclass/modules/login/model/account_model.dart';

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
    futureMistakeClass = fetchAccountsByGroup();
  }

  Future<List<AccountModel>> fetchAccountsByGroup() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('ACCOUNT')
        .where('_groupID', isEqualTo: '001')
        .get();
    return snapshot.docs.map((doc) => AccountModel.fromFirestore(doc)).toList();
  }

  final accountRepository = AccountRepository();

  Future<List<AccountEditModel>> fetchDatatttt(String idGroup) async {
    try {
      return await accountRepository.fetchAccountsEditByGroup1(idGroup);
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  Future<List<AccountEditModel>> fetchDatatttt2(String idGroup) async {
    try {
      return await accountRepository.fetchAccountsEditByGroup2(idGroup);
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }

  Widget _buildAccountList(String groupId) {
    return FutureBuilder<List<AccountEditModel>>(
      future: fetchDatatttt(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có tài khoản.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => ItemAccount(
            accountEditModel: snapshot.data![index],
          ),
        );
      },
    );
  }

  Widget _buildAccountList1(String groupId) {
    return FutureBuilder<List<AccountEditModel>>(
      future: fetchDatatttt2(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có tài khoản.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) => ItemAccount(
            accountEditModel: snapshot.data![index],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Quản lý tài khoản',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nút tạo tài khoản (nhiều / 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: const TabarListAcc(),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tạo nhiều tài khoản',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AccountCreatAccPage.routeName),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tạo 1 tài khoản',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Nút xuất DS tài khoản
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const DialogExportAcc();
                    },
                  );
                },
                icon: const Icon(Icons.file_download),
                label: const Text('Xuất DS tài khoản'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // TextField tìm kiếm
              TextField(
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  prefixIcon: const Icon(
                    Icons.search_outlined,
                    size: 24,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tab hiển thị danh sách tài khoản theo nhóm
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: const [
                          Tab(
                              child: Text('BGH',
                                  maxLines: 2, overflow: TextOverflow.visible)),
                          Tab(
                              child: Text('Giáo viên',
                                  maxLines: 2, overflow: TextOverflow.visible)),
                          Tab(
                              child: Text('Học sinh',
                                  maxLines: 2, overflow: TextOverflow.visible)),
                          Tab(
                              child: Text('PHHS',
                                  maxLines: 2, overflow: TextOverflow.visible)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAccountList('001'),
                            _buildAccountList('002'),
                            _buildAccountList('003'),
                            _buildAccountList('004'),
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
      ),
    );
  }
}

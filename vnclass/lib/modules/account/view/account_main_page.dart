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
  final accountRepository = AccountRepository();

  @override
  void initState() {
    super.initState();
  }

  Future<List<AccountEditModel>> fetchDatatttt() async {
    try {
      return await accountRepository.fetchAccountsEditByGroup1('hocSinh');
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return [];
    }
  }

  Future<List<AccountEditModel>> fetchDatatttt2() async {
    try {
      return await accountRepository.fetchAccountsEditByGroup2('giaoVien');
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return [];
    }
  }

  Future<List<AccountEditModel>> fetchDatatttt3() async {
    try {
      return await accountRepository.fetchAccountsEditByGroup3('phuHuynh');
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return [];
    }
  }

  Widget _buildAccountList(
      String groupId, Future<List<AccountEditModel>> Function() fetchData) {
    return FutureBuilder<List<AccountEditModel>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi.'));
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
              // Header với các nút hành động
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.85,
                                height:
                                    MediaQuery.of(context).size.height * 0.55,
                                child: const TabarListAcc(),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2), // Xanh đậm
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Tạo nhiều tài khoản',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const DialogExportAcc();
                        },
                      );
                    },
                    icon: const Icon(Icons.file_download, color: Colors.white),
                    label: const Text('Xuất DS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C), // Xanh lá đậm
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AccountCreatAccPage.routeName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF0288D1), // Xanh nhạt hơn
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Tạo 1 tài khoản',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Thanh tìm kiếm
              TextField(
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tài khoản...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(
                    Icons.search_outlined,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1976D2),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tab hiển thị danh sách tài khoản
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          labelColor: const Color(0xFF1976D2),
                          unselectedLabelColor: Colors.grey.shade600,
                          indicatorColor: const Color(0xFF1976D2),
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          tabs: const [
                            Tab(text: 'BGH'),
                            Tab(text: 'Giáo viên'),
                            Tab(text: 'Học sinh'),
                            Tab(text: 'PHHS'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TabBarView(
                            children: [
                              _buildAccountList('banGH', fetchDatatttt2),
                              _buildAccountList('giaoVien', fetchDatatttt2),
                              _buildAccountList('hocSinh', fetchDatatttt),
                              _buildAccountList('phuHuynh', fetchDatatttt3),
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
        ),
      ),
    );
  }
}

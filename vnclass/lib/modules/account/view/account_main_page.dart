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

class _AccountMainPageState extends State<AccountMainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final accountRepository = AccountRepository();

  List<AccountEditModel> banGHData = [];
  List<AccountEditModel> giaoVienData = [];
  List<AccountEditModel> hocSinhData = [];
  List<AccountEditModel> phuHuynhData = [];

  List<bool> isLoading = [true, true, true, true];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = [true, true, true, true];
    });

    await Future.wait([
      fetchDatatttt2('banGH').then((data) {
        setState(() {
          banGHData = data;
          isLoading[0] = false;
        });
      }),
      fetchDatatttt2('giaoVien').then((data) {
        setState(() {
          giaoVienData = data;
          isLoading[1] = false;
        });
      }),
      fetchDatatttt().then((data) {
        setState(() {
          hocSinhData = data;
          isLoading[2] = false;
        });
      }),
      fetchDatatttt3().then((data) {
        setState(() {
          phuHuynhData = data;
          isLoading[3] = false;
        });
      }),
    ]).catchError((e) {
      print('Lỗi khi tải tất cả dữ liệu: $e');
      setState(() {
        isLoading = [false, false, false, false];
      });
    });
  }

  Future<List<AccountEditModel>> fetchDatatttt() async {
    try {
      return await accountRepository.fetchAccountsEditByGroup1('hocSinh');
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return [];
    }
  }

  Future<List<AccountEditModel>> fetchDatatttt2(String id) async {
    try {
      return await accountRepository.fetchAccountsEditByGroup2(id);
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

  void _updateAccount(AccountEditModel? updatedAccount, bool isDeleted) {
    setState(() {
      int tabIndex = _tabController.index;
      List<AccountEditModel> currentData = _getDataForTab(tabIndex);
      if (updatedAccount != null) {
        int index = currentData.indexWhere((item) =>
            item.accountModel.idAcc == updatedAccount.accountModel.idAcc);
        if (index != -1) {
          if (isDeleted) {
            currentData.removeAt(index); // Xóa tài khoản khỏi danh sách
          } else {
            currentData[index] = updatedAccount; // Cập nhật nếu không bị xóa
          }
        }
      }
    });
  }

  List<AccountEditModel> _getDataForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return banGHData;
      case 1:
        return giaoVienData;
      case 2:
        return hocSinhData;
      case 3:
        return phuHuynhData;
      default:
        return [];
    }
  }

  Widget _buildAccountList(int tabIndex) {
    List<AccountEditModel> data = _getDataForTab(tabIndex);
    if (isLoading[tabIndex] && data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data.isEmpty) {
      return const Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Text('Không có tài khoản.'),
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) => ItemAccount(
        accountEditModel: data[index],
        onDataChanged: (updatedAccount, isDeleted) {
          _updateAccount(updatedAccount, isDeleted);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Quản lý tài khoản',
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: const Color(0xFF388E3C),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    height: MediaQuery.of(context).size.height *
                                        0.55,
                                    child: const TabarListAcc(),
                                  ),
                                );
                              },
                            ).then((_) => _loadAllData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
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
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  height: MediaQuery.of(context).size.height *
                                      0.65, // Tăng chiều cao lên 65%
                                  child: const DialogExportAcc(),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.file_download,
                            color: Colors.white),
                        label: const Text(
                          'Xuất DS',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
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
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AccountCreatAccPage.routeName)
                                .then((_) => _loadAllData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0288D1),
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
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
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
                      controller: _tabController,
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
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
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
                      controller: _tabController,
                      children: [
                        _buildAccountList(0),
                        _buildAccountList(1),
                        _buildAccountList(2),
                        _buildAccountList(3),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

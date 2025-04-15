import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Thêm kIsWeb
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/confirmation_dialog.dart';

import 'package:vnclass/modules/account/controller/account_repository.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';

import 'package:vnclass/web/account/account_create_acc_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/account_create_acc_page_web.dart';
import 'package:vnclass/web/account/account_edit_acc_page_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/account_edit_acc_page_web.dart';
import 'package:vnclass/web/account/dialog_export_acc_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/dialog_export_acc_web.dart';
import 'package:vnclass/web/account/tabar_list_acc_web.dart'
    if (kIsWeb) 'package:vnclass/web/account/tabar_list_acc_web.dart';

class AccountMainPageWeb extends StatefulWidget {
  const AccountMainPageWeb({super.key});
  static const String routeName = '/account_main_page_web';

  @override
  State<AccountMainPageWeb> createState() => _AccountMainPageWebState();
}

class _AccountMainPageWebState extends State<AccountMainPageWeb> {
  // Pills labels cho 4 nhóm
  final List<String> _pillsLabels = [
    'Ban Giám Hiệu',
    'Giáo viên',
    'Học sinh',
    'PHHS',
  ];
  int _selectedIndex = 0;

  final accountRepository = AccountRepository();

  List<AccountEditModel> banGHData = [];
  List<AccountEditModel> giaoVienData = [];
  List<AccountEditModel> hocSinhData = [];
  List<AccountEditModel> phuHuynhData = [];

  List<bool> isLoading = [true, true, true, true];

  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = [true, true, true, true];
    });
    try {
      await Future.wait([
        _fetchDataByGroup('banGH').then((data) {
          setState(() {
            banGHData = data;
            isLoading[0] = false;
          });
        }),
        _fetchDataByGroup('giaoVien').then((data) {
          setState(() {
            giaoVienData = data;
            isLoading[1] = false;
          });
        }),
        _fetchHocSinhData().then((data) {
          setState(() {
            hocSinhData = data;
            isLoading[2] = false;
          });
        }),
        _fetchDataByGroup3('phuHuynh').then((data) {
          setState(() {
            phuHuynhData = data;
            isLoading[3] = false;
          });
        }),
      ]);
    } catch (e) {
      debugPrint('Lỗi khi tải dữ liệu: $e');
      setState(() {
        isLoading = [false, false, false, false];
      });
    }
  }

  Future<List<AccountEditModel>> _fetchHocSinhData() async {
    try {
      return await accountRepository.fetchAccountsEditByGroup1('hocSinh');
    } catch (e) {
      debugPrint('Có lỗi xảy ra: $e');
      return [];
    }
  }

  Future<List<AccountEditModel>> _fetchDataByGroup(String groupID) async {
    try {
      return await accountRepository.fetchAccountsEditByGroup2(groupID);
    } catch (e) {
      debugPrint('Có lỗi xảy ra: $e');
      return [];
    }
  }

  Future<List<AccountEditModel>> _fetchDataByGroup3(String groupID) async {
    try {
      return await accountRepository.fetchAccountsEditByGroup3(groupID);
    } catch (e) {
      debugPrint('Có lỗi xảy ra: $e');
      return [];
    }
  }

  List<AccountEditModel> _getDataForIndex(int index) {
    switch (index) {
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

  List<AccountEditModel> _getFilteredData() {
    if (searchText.isEmpty) return _getDataForIndex(_selectedIndex);
    List<AccountEditModel> allData = [
      ...banGHData,
      ...giaoVienData,
      ...hocSinhData,
      ...phuHuynhData,
    ];
    return allData.where((acc) {
      return acc.accountModel.accName
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
  }

  void _updateAccount(AccountEditModel? updatedAccount, bool isDeleted) {
    if (updatedAccount == null) return;
    setState(() {
      List<AccountEditModel> currentData = _getDataForIndex(_selectedIndex);
      int idx = currentData.indexWhere((item) =>
          item.accountModel.idAcc == updatedAccount.accountModel.idAcc);
      if (idx != -1) {
        if (isDeleted) {
          currentData.removeAt(idx);
        } else {
          currentData[idx] = updatedAccount;
        }
      }
    });
  }

  // /// Hàm xử lý chuyển sang trang chỉnh sửa tài khoản
  // void _handleEdit(BuildContext context, AccountEditModel acc) async {
  //   final result = await Navigator.pushNamed(
  //     context,
  //     AccountEditAccPage.routeName,
  //     arguments: acc,
  //   );
  //   if (result != null && result is AccountEditModel) {
  //     setState(() {
  //       _updateAccount(result, false);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Quản lý tài khoản',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.person, size: 28, color: Color(0xFF1E3A8A)),
          onPressed: () {},
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: Colors.blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng trên: pills, search bar, và action buttons (trên cùng một hàng)
                    _buildTopRow(context),
                    const SizedBox(height: 24),
                    // Danh sách tài khoản hiển thị dạng grid card
                    SizedBox(
                      height: 600,
                      child: _buildGridCards(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Column(
      children: [
        _buildPillsRow(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildSearchBar(),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPillsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_pillsLabels.length, (index) {
          bool isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              margin: EdgeInsets.only(
                  right: index < _pillsLabels.length - 1 ? 12 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
                ),
              ),
              child: Text(
                _pillsLabels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => searchText = value),
        style: const TextStyle(fontSize: 18),
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm tài khoản...',
          border: InputBorder.none,
          icon: Icon(Icons.search, size: 28),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(AccountCreateAccPageWeb.routeName)
                  .then((_) => _loadAllData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Tạo 1 tài khoản',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const TabarListAccWeb(),
                    ),
                  );
                },
              ).then((_) => _loadAllData());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Tạo nhiều tài khoản',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const DialogExportAccWeb(),
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Xuất DS',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridCards() {
    List<AccountEditModel> data = _getFilteredData();
    if (isLoading[_selectedIndex] && data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (data.isEmpty) {
      return const Center(child: Text('Không có tài khoản.'));
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: data.map((acc) => _buildAccountCard(acc)).toList(),
    );
  }

  // /// Lấy dữ liệu đã được lọc theo từ khóa tìm kiếm (nếu có)
  // List<AccountEditModel> _getFilteredData() {
  //   if (searchText.isEmpty) return _getDataForIndex(_selectedIndex);
  //   List<AccountEditModel> allData = [
  //     ...banGHData,
  //     ...giaoVienData,
  //     ...hocSinhData,
  //     ...phuHuynhData,
  //   ];
  //   return allData.where((acc) {
  //     return acc.accountModel.accName
  //         .toLowerCase()
  //         .contains(searchText.toLowerCase());
  //   }).toList();
  // }

  Widget _buildAccountCard(AccountEditModel acc) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(FontAwesomeIcons.user, color: Colors.blue),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(FontAwesomeIcons.ellipsisH, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    _handleEdit(context, acc);
                  } else if (value == 'remove') {
                    _handleDelete(context, acc);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Chỉnh sửa'),
                  ),
                  if (acc.accountModel.goupID !=
                      'phuHuynh') // Không cho phép xóa PHHS trực tiếp
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Xóa'),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            acc.accountModel.accName,
            style:
                GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            acc.accountModel.email,
            style:
                GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            acc.accountModel.goupID,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ' ',
            style:
                GoogleFonts.roboto(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

// Hàm xử lý xóa tài khoản
  void _handleDelete(BuildContext context, AccountEditModel acc) {
    ConfirmationDialog.show(
      context: context,
      title: 'Xác nhận xóa',
      message: 'Bạn có chắc chắn muốn xóa tài khoản này không?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
      confirmColor: Colors.redAccent,
    ).then((confirmed) {
      if (confirmed == true) {
        _deleteAccount(context, acc);
      }
    });
  }

// Hàm xóa tài khoản
  Future<void> _deleteAccount(
      BuildContext context, AccountEditModel acc) async {
    final String groupId = acc.accountModel.goupID;
    final String accountId = acc.accountModel.idAcc;

    try {
      if (groupId == 'banGH' || groupId == 'giaoVien') {
        await Future.wait([
          FirebaseFirestore.instance
              .collection('ACCOUNT')
              .doc(accountId)
              .delete(),
          FirebaseFirestore.instance
              .collection('TEACHER')
              .doc(accountId)
              .delete(),
        ]);
      } else if (groupId == 'hocSinh') {
        final studentDoc = await FirebaseFirestore.instance
            .collection('STUDENT')
            .doc(accountId)
            .get();
        final String? parentId = studentDoc.data()?['P_id'];

        final String? classId = acc.studentDetailModel?.classID;
        if (classId != null) {
          final classDoc = await FirebaseFirestore.instance
              .collection('CLASS')
              .doc(classId)
              .get();
          if (classDoc.exists) {
            final currentAmount = classDoc.data()!['_amount'] as num? ?? 0;
            final newAmount = currentAmount > 0 ? currentAmount.toInt() - 1 : 0;
            await FirebaseFirestore.instance
                .collection('CLASS')
                .doc(classId)
                .update({'_amount': newAmount});
          }
        }

        await Future.wait([
          FirebaseFirestore.instance
              .collection('ACCOUNT')
              .doc(accountId)
              .delete(),
          FirebaseFirestore.instance
              .collection('STUDENT')
              .doc(accountId)
              .delete(),
          if (acc.classMistakeModel?.academicYear != null)
            FirebaseFirestore.instance
                .collection('STUDENT_DETAIL')
                .doc('$accountId${acc.classMistakeModel!.academicYear}')
                .delete(),
          if (acc.classMistakeModel?.academicYear != null)
            FirebaseFirestore.instance
                .collection('CONDUCT_MONTH')
                .doc('$accountId${acc.classMistakeModel!.academicYear}')
                .delete(),
          if (parentId != null)
            FirebaseFirestore.instance
                .collection('ACCOUNT')
                .doc(parentId)
                .delete(),
          if (parentId != null)
            FirebaseFirestore.instance
                .collection('PARENT')
                .doc(parentId)
                .delete(),
        ]);
      } else {
        // Không xử lý xóa PHHS ở đây, vì đã ẩn tùy chọn xóa
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa tài khoản thành công!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      setState(() {
        _updateAccount(acc, true); // Cập nhật danh sách, đánh dấu là đã xóa
      });
    } catch (e) {
      debugPrint('Lỗi khi xóa tài khoản: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa tài khoản thất bại!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Hàm chuyển sang trang chỉnh sửa tài khoản
  void _handleEdit(BuildContext context, AccountEditModel acc) async {
    final result = await Navigator.pushNamed(
      context,
      AccountEditAccPageWeb.routeName,
      arguments: acc,
    );
    if (result != null && result is AccountEditModel) {
      setState(() {
        _updateAccount(result, false);
      });
    }
  }
}

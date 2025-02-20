import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
import 'package:vnclass/modules/account/widget/item_permission_acc.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';
import 'package:http/http.dart' as http;

class AccountEditAccPage extends StatefulWidget {
  const AccountEditAccPage({super.key});

  static const String routeName = '/account_edit_acc_page';

  @override
  State<AccountEditAccPage> createState() => _AccountEditAccPageState();
}

class _AccountEditAccPageState extends State<AccountEditAccPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _accountTypeController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  bool _isShowPass = false;
  bool _isShowPassAgain = false;
  bool _isInit = true; // dùng để khởi tạo một lần

  // Biến trạng thái cho giới tính, năm học và chế độ chỉnh sửa
  String? _selectedGender;
  String? _selectedAcademicYear;
  bool _isEditing =
      false; // false: không cho phép chỉnh sửa, true: cho phép chỉnh sửa

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final AccountEditModel accountEditModel =
          ModalRoute.of(context)!.settings.arguments as AccountEditModel;

      // Gán dữ liệu cho các trường thông tin tài khoản
      _accountTypeController.text =
          accountEditModel.groupModel?.groupName ?? '';
      _accountNameController.text =
          accountEditModel.accountModel.userName ?? '';
      _userNameController.text = accountEditModel.accountModel.accName ?? '';
      _dateController.text = accountEditModel.studentMistakeModel?.birthday ??
          accountEditModel.teacherModel?.birthday ??
          accountEditModel.parentModel?.birthday ??
          '';
      _emailController.text = accountEditModel.accountModel.email ?? '';
      _phoneController.text = accountEditModel.accountModel.phone ?? '';
      _classController.text =
          accountEditModel.classMistakeModel?.className ?? '';

      // Khởi tạo giá trị cho giới tính từ studentMistakeModel
      _selectedGender = accountEditModel.studentMistakeModel?.gender ??
          accountEditModel.teacherModel?.gender ??
          accountEditModel.parentModel?.gender ??
          'Nam';

      // Khởi tạo giá trị cho năm học từ classMistakeModel
      _selectedAcademicYear =
          accountEditModel.classMistakeModel?.academicYear ?? '';

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  void onToggleShowPass() {
    setState(() {
      _isShowPass = !_isShowPass;
    });
  }

  void onToggleShowPassAgain() {
    setState(() {
      _isShowPassAgain = !_isShowPassAgain;
    });
  }

  final String apiToken = '28118374-7d32-42fd-bf28-5f574262087e';
  Future<void> sendEmail() async {
    final url = 'https://api.postmarkapp.com/email';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'X-Postmark-Server-Token': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'From': 'suongb2103561@student.ctu.edu.vn',
        'To': 'dosuong16203@gmail.com',
        'Subject': 'Cấp lại mật khẩu',
        'TextBody': 'Mật khẩu mới của bạn là: 123',
      }),
    );

    if (response.statusCode == 200) {
      print('Email sent successfully!');
    } else {
      print('Failed to send email: ${response.body}');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> updateAccountPassword(
      String accountId, String newPassword) async {
    String newPassHash = _hashPassword(newPassword);
    try {
      // Lấy tham chiếu tới collection ACCOUNT
      CollectionReference accounts =
          FirebaseFirestore.instance.collection('ACCOUNT');

      // Tìm tài liệu có trường _id = accountId
      QuerySnapshot querySnapshot =
          await accounts.where('_id', isEqualTo: accountId).get();

      if (querySnapshot.docs.isNotEmpty) {
        // Nếu tìm thấy tài liệu, lấy doc đầu tiên
        DocumentSnapshot document = querySnapshot.docs.first;

        // Cập nhật trường pass
        await accounts.doc(document.id).update({'_pass': newPassHash});
        print('Cập nhật mật khẩu thành công');
        return true;
      } else {
        print('Không tìm thấy tài liệu nào với _id = $accountId');
        return false;
      }
    } catch (e) {
      print('Lỗi khi cập nhật mật khẩu: $e');
      return false;
    }
  }

  /// Tab 1: Cập nhật thông tin tài khoản
  Widget _buildInfoTab(BuildContext context, List years) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Widget chuyển đổi chế độ chỉnh sửa
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Chế độ chỉnh sửa",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _isEditing,
                  onChanged: (value) {
                    setState(() {
                      _isEditing = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Loại tài khoản (luôn không cho chỉnh sửa)
          TextfieldWidget(
            labelText: 'Loại tài khoản',
            controller: _accountTypeController,
            enabled: false, // luôn không cho chỉnh sửa
          ),
          const SizedBox(height: 16),
          // Tên tài khoản (luôn không cho chỉnh sửa)
          TextfieldWidget(
            labelText: 'Tên tài khoản',
            controller: _accountNameController,
            enabled: false,
          ),
          const SizedBox(height: 16),
          // Tên người dùng (cho chỉnh sửa khi _isEditing == true)
          TextfieldWidget(
            labelText: 'Tên người dùng',
            controller: _userNameController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          // Ngày (sử dụng TextField gốc, chỉ cho chọn ngày khi _isEditing)
          TextField(
            controller: _dateController,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Date',
              suffixIcon: Icon(
                FontAwesomeIcons.calendar,
                color: _isEditing ? ColorApp.primaryColor : Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: _isEditing
                        ? ColorApp.primaryColor
                        : Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: _isEditing ? Colors.blue : Colors.grey.shade400),
              ),
            ),
            readOnly: !_isEditing, // chỉ cho chọn khi đang chỉnh sửa
            onTap: _isEditing ? _selectDate : null,
          ),
          const SizedBox(height: 16),
          // Email
          TextfieldWidget(
            labelText: 'Email',
            controller: _emailController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          // SĐT
          TextfieldWidget(
            labelText: 'SĐT',
            controller: _phoneController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          // Lớp
          TextfieldWidget(
            labelText: 'Lớp',
            controller: _classController,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          // Năm học
          Row(
            children: [
              const Text('Năm học:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: DropMenuWidget(
                  items: years,
                  selectedItem: _selectedAcademicYear,
                  enabled: _isEditing,
                  onChanged: (value) {
                    setState(() {
                      _selectedAcademicYear = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Giới tính
          Row(
            children: [
              const Text('Giới tính:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: RadioButtonWidget(
                  options: const ['Nam', 'Nữ'],
                  selectedValue: _selectedGender,
                  enabled: _isEditing,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Nút Lưu thay đổi
          Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  title: 'Lưu Thay Đổi',
                  ontap: () {
                    // In thông tin ra terminal khi lưu
                    print("Loại tài khoản: ${_accountTypeController.text}");
                    print("Tên tài khoản: ${_accountNameController.text}");
                    print("Tên người dùng: ${_userNameController.text}");
                    print("Ngày: ${_dateController.text}");
                    print("Email: ${_emailController.text}");
                    print("SĐT: ${_phoneController.text}");
                    print("Lớp: ${_classController.text}");
                    print("Năm học: $_selectedAcademicYear");
                    print("Giới tính: $_selectedGender");

                    // Có thể hiển thị dialog xác nhận hoặc xử lý lưu thay đổi ở đây
                    CustomDialogWidget.showConfirmationDialog(
                      context,
                      'Xác nhận tạo tài khoản?',
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ButtonWidget(
                  title: 'Thoát',
                  color: Colors.red,
                  ontap: () => Navigator.of(context).pop(),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Tab 2: Cập nhật quyền
  Widget _buildPermissionTab(List<String> permissionList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ChecklistTab(
        listA: permissionList,
        listB: permissionList,
      ),
    );
  }

  /// Tab 3: Khôi phục mật khẩu
  Widget _buildResetPasswordTab(
      BuildContext context, AccountEditModel accountEditModel) {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Khôi phục mật khẩu",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Nhấn nút bên dưới để nhận hướng dẫn khôi phục mật khẩu qua email.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                title: "Reset pass",
                ontap: () async {
                  print("Reset pass button tapped");
                  bool success = await updateAccountPassword(
                      accountEditModel.accountModel.idAcc, '123');

                  // Hiển thị SnackBar thông báo thành công hoặc lỗi
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Cập nhật mật khẩu thành công!'
                          : 'Cập nhật mật khẩu thất bại!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Gửi email khôi phục mật khẩu
                  if (success) {
                    sendEmail();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    final years = yearProvider.years;

    // Xử lý danh sách quyền
    List<String> permissionList = [];
    void addSecondElementsFromPermissions(
        Map<String, List<dynamic>> permissions) {
      for (var entry in permissions.entries) {
        var value = entry.value;
        if (value.length > 1) {
          permissionList.add(value[1]);
        }
      }
    }

    final AccountEditModel accountEditModel =
        ModalRoute.of(context)!.settings.arguments as AccountEditModel;
    addSecondElementsFromPermissions(accountEditModel.groupModel!.permission);
    permissionList.addAll(accountEditModel.accountModel.permission);

    return AppBarWidget(
      implementLeading: true,
      titleString: accountEditModel.accountModel.accName ?? '',
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              isScrollable: false, // Các tab sẽ chia đều chiều ngang màn hình
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(
                  child: Center(
                    child: Text(
                      'Cập nhật thông tin',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2, // hoặc bỏ qua nếu muốn không giới hạn
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: Text(
                      'Cập nhật quyền',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ),
                ),
                Tab(
                  child: Center(
                    child: Text(
                      'Khôi phục mật khẩu',
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildInfoTab(context, years),
                  _buildPermissionTab(permissionList),
                  _buildResetPasswordTab(context, accountEditModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

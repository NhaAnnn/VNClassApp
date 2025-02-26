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
  bool _isInit = true;
  String? _selectedGender;
  String? _selectedAcademicYear;
  bool _isEditing = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final AccountEditModel accountEditModel =
          ModalRoute.of(context)!.settings.arguments as AccountEditModel;
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
      _selectedGender = accountEditModel.studentMistakeModel?.gender ??
          accountEditModel.teacherModel?.gender ??
          accountEditModel.parentModel?.gender ??
          'Nam';
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
    setState(() => _isShowPass = !_isShowPass);
  }

  void onToggleShowPassAgain() {
    setState(() => _isShowPassAgain = !_isShowPassAgain);
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
      CollectionReference accounts =
          FirebaseFirestore.instance.collection('ACCOUNT');
      QuerySnapshot querySnapshot =
          await accounts.where('_id', isEqualTo: accountId).get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot document = querySnapshot.docs.first;
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

  Widget _buildInfoTab(BuildContext context, List years) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chế độ chỉnh sửa
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chế độ chỉnh sửa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  value: _isEditing,
                  activeColor: const Color(0xFF1976D2),
                  onChanged: (value) => setState(() => _isEditing = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Các trường thông tin
          _buildTextField('Loại tài khoản', _accountTypeController,
              enabled: false),
          _buildTextField('Tên tài khoản', _accountNameController,
              enabled: false),
          _buildTextField('Tên người dùng', _userNameController,
              enabled: _isEditing),
          _buildDateField(),
          _buildTextField('Email', _emailController, enabled: _isEditing),
          _buildTextField('SĐT', _phoneController, enabled: _isEditing),
          _buildTextField('Lớp', _classController, enabled: _isEditing),
          _buildDropdownField(
              'Năm học',
              years,
              _selectedAcademicYear,
              _isEditing,
              (value) => setState(() => _selectedAcademicYear = value)),
          _buildRadioField('Giới tính', ['Nam', 'Nữ'], _selectedGender,
              _isEditing, (value) => setState(() => _selectedGender = value)),
          const SizedBox(height: 32),
          // Nút hành động
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isEditing
                      ? () {
                          print(
                              "Loại tài khoản: ${_accountTypeController.text}");
                          print(
                              "Tên tài khoản: ${_accountNameController.text}");
                          print("Tên người dùng: ${_userNameController.text}");
                          print("Ngày: ${_dateController.text}");
                          print("Email: ${_emailController.text}");
                          print("SĐT: ${_phoneController.text}");
                          print("Lớp: ${_classController.text}");
                          print("Năm học: $_selectedAcademicYear");
                          print("Giới tính: $_selectedGender");
                          CustomDialogWidget.showConfirmationDialog(
                            context,
                            'Xác nhận lưu thay đổi?',
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Thoát',
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
        ],
      ),
    );
  }

  Widget _buildPermissionTab(List<String> permissionList) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quyền truy cập',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
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
              child: ChecklistTab(
                listA: permissionList,
                listB: permissionList,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetPasswordTab(
      BuildContext context, AccountEditModel accountEditModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Khôi phục mật khẩu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nhấn nút bên dưới để gửi mật khẩu mới qua email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  bool success = await updateAccountPassword(
                      accountEditModel.accountModel.idAcc, '123');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Cập nhật mật khẩu thành công!'
                          : 'Cập nhật mật khẩu thất bại!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  if (success) sendEmail();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Gửi mật khẩu mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
    final AccountEditModel accountEditModel =
        ModalRoute.of(context)!.settings.arguments as AccountEditModel;

    List<String> permissionList = [];
    void addSecondElementsFromPermissions(
        Map<String, List<dynamic>> permissions) {
      for (var entry in permissions.entries) {
        var value = entry.value;
        if (value.length > 1) permissionList.add(value[1]);
      }
    }

    addSecondElementsFromPermissions(accountEditModel.groupModel!.permission);
    permissionList.addAll(accountEditModel.accountModel.permission);

    return AppBarWidget(
      implementLeading: true,
      titleString: accountEditModel.accountModel.accName ?? '',
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                tabs: const [
                  Tab(text: 'Thông tin'),
                  Tab(text: 'Quyền'),
                  Tab(text: 'Mật khẩu'),
                ],
              ),
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

  // Helper methods
  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextfieldWidget(
        labelText: label,
        controller: controller,
        enabled: enabled,
        textStyle: TextStyle(
          fontSize: 16,
          color: enabled ? Colors.black87 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _dateController,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: 'Ngày sinh',
          labelStyle: TextStyle(color: Colors.grey.shade600),
          suffixIcon: Icon(
            FontAwesomeIcons.calendar,
            color: _isEditing ? const Color(0xFF1976D2) : Colors.grey.shade400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        readOnly: true,
        onTap: _isEditing ? _selectDate : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List items, String? selectedItem,
      bool enabled, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropMenuWidget(
              items: items,
              selectedItem: selectedItem,
              enabled: enabled,
              hintText: 'Chọn $label',
              // onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioField(String label, List<String> options,
      String? selectedValue, bool enabled, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RadioButtonWidget(
              options: options,
              selectedValue: selectedValue,
              enabled: enabled,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/main_home/controller/class_provider.dart';
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

  late List<String> groupPermissions; // Permissions từ group (cố định)
  late List<String>
      accountPermissions; // Permissions từ account (có thể chỉnh sửa)
  late List<String>
      dbPermissions; // Permissions từ Firestore (có thể chỉnh sửa)

  bool _isShowPass = false;
  bool _isShowPassAgain = false;
  bool _isInit = true;
  String? _selectedGender;
  String? _selectedAcademicYear;
  bool _isEditing = false;
  String? _selectedClass;

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

      _selectedGender = accountEditModel.studentMistakeModel?.gender ??
          accountEditModel.teacherModel?.gender ??
          accountEditModel.parentModel?.gender ??
          'Nam';

      // Lấy danh sách years từ YearProvider
      final yearProvider = Provider.of<YearProvider>(context, listen: false);
      final years = yearProvider.years;

      // Kiểm tra academicYear
      String? academicYear = accountEditModel.classMistakeModel?.academicYear;
      _selectedAcademicYear =
          (academicYear != null && years.contains(academicYear))
              ? academicYear
              : null;

      // Kiểm tra className với danh sách classes
      // final List<String> classes = [
      //   'Lớp 6A',
      //   'Lớp 6B',
      //   'Lớp 7A',
      //   'Lớp 7B',
      //   'Lớp 8A',
      //   'Lớp 8B',
      // ];
      final classProvider = Provider.of<ClassProvider>(context);
      final classes = classProvider.classNames.toString().toUpperCase();
      String? className =
          accountEditModel.classMistakeModel?.className.toUpperCase();
      _selectedClass =
          (className != null && classes.contains(className)) ? className : null;

      // Khởi tạo danh sách permissions
      groupPermissions = [];
      accountPermissions = List.from(accountEditModel.accountModel.permission);
      dbPermissions = [];

      // Lấy permissions từ group
      accountEditModel.groupModel!.permission.forEach((key, value) {
        if (value.length > 1) groupPermissions.add(value[1]);
      });

      _isInit = false;

      // Lấy permissions từ Firestore
      fetchDbPermissions().then((dbPerms) {
        setState(() {
          // Loại bỏ trùng lặp với groupPermissions và accountPermissions
          dbPermissions = dbPerms
              .where((perm) =>
                  !groupPermissions.contains(perm) &&
                  !accountPermissions.contains(perm))
              .toList();
        });
      });
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
        'To': 'nhanb2110134@student.ctu.edu.vn',
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
    // Thêm vào _AccountEditAccPageState
    // final List<String> classes = [
    //   'Lớp 6A',
    //   'Lớp 6B',
    //   'Lớp 7A',
    //   'Lớp 7B',
    //   'Lớp 8A',
    //   'Lớp 8B',
    // ]; // Thay bằng danh sách thực tế của bạn
    final yearProvider = Provider.of<YearProvider>(context);
    final years = yearProvider.years;
    final classProvider = Provider.of<ClassProvider>(context);
    final classes = classProvider.classNames;
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
          // Thay _buildTextField bằng _buildDropdownField cho Lớp
          _buildDropdownField(
            'Lớp',
            classes, // Danh sách lớp
            _selectedClass,
            _isEditing,
            (value) => setState(() => _selectedClass = value),
          ),
          _buildDropdownField(
            'Năm học',
            years,
            _selectedAcademicYear,
            _isEditing,
            (value) => setState(() => _selectedAcademicYear = value),
          ),
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
                          // print(
                          //     "Loại tài khoản: ${_accountTypeController.text}");
                          // print(
                          //     "Tên tài khoản: ${_accountNameController.text}");
                          // print("Tên người dùng: ${_userNameController.text}");
                          // print("Ngày: ${_dateController.text}");
                          // print("Email: ${_emailController.text}");
                          // print("SĐT: ${_phoneController.text}");
                          // print("Lớp: $_selectedClass");
                          // print("Năm học: $_selectedAcademicYear");
                          // print("Giới tính: $_selectedGender");
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

  Widget _buildPermissionTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nội dung permissions với khả năng cuộn tổng thể
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần permissions của group (cố định, luôn check)
                  ExpansionTile(
                    title: const Text(
                      'Quyền của nhóm (cố định)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            children: groupPermissions.map((perm) {
                              return CheckboxListTile(
                                value: true,
                                title: Text(perm),
                                onChanged: null,
                                activeColor: const Color(0xFF388E3C),
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                enabled: false,
                                dense: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phần permissions của account (có thể check/uncheck)
                  ExpansionTile(
                    title: const Text(
                      'Quyền của tài khoản',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            children: accountPermissions.map((perm) {
                              return CheckboxListTile(
                                value: true,
                                title: Text(perm),
                                onChanged: (bool? value) {
                                  setState(() {
                                    accountPermissions.remove(perm);
                                    dbPermissions.add(perm);
                                  });
                                },
                                activeColor: const Color(0xFF388E3C),
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phần permissions từ Firestore (có thể check/uncheck)
                  ExpansionTile(
                    title: const Text(
                      'Quyền từ cơ sở dữ liệu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            children: dbPermissions.map((perm) {
                              return CheckboxListTile(
                                value: false,
                                title: Text(perm),
                                onChanged: (bool? value) {
                                  setState(() {
                                    dbPermissions.remove(perm);
                                    accountPermissions.add(perm);
                                  });
                                },
                                activeColor: const Color(0xFF388E3C),
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút hành động
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final AccountEditModel accountEditModel =
                        ModalRoute.of(context)!.settings.arguments
                            as AccountEditModel;
                    try {
                      CollectionReference accounts =
                          FirebaseFirestore.instance.collection('ACCOUNT');
                      QuerySnapshot querySnapshot = await accounts
                          .where('_id',
                              isEqualTo: accountEditModel.accountModel.idAcc)
                          .get();
                      if (querySnapshot.docs.isNotEmpty) {
                        DocumentSnapshot document = querySnapshot.docs.first;
                        await accounts.doc(document.id).update({
                          '_permission':
                              accountPermissions, // Lưu mảng permissions
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lưu thay đổi quyền thành công!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không tìm thấy tài khoản!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      print('Lỗi khi lưu permissions: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lưu thay đổi thất bại!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
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

  Future<List<String>> fetchDbPermissions() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('PERMISSION').get();
      return snapshot.docs
          .map((doc) => doc['_permisssionName'] as String)
          .toList();
    } catch (e) {
      print('Lỗi khi lấy permissions từ Firestore: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    final years = yearProvider.years;
    final AccountEditModel accountEditModel =
        ModalRoute.of(context)!.settings.arguments as AccountEditModel;

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
                  _buildPermissionTab(), // Gọi hàm mới
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
      child: DropdownButtonFormField<String>(
        value: selectedItem,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade600, // Màu nhãn khi ở trạng thái nghỉ
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: selectedItem != null
                ? const Color(0xFF1976D2) // Xanh lá đậm khi có giá trị
                : enabled
                    ? const Color(0xFF1976D2) // Xanh dương khi focus
                    : Colors.grey.shade400, // Xám nhạt khi disabled
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF1976D2),
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: enabled
              ? Colors.black87
              : Colors.grey.shade600, // Đồng bộ với TextfieldWidget
        ),
        hint: Text(
          'Chọn $label',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade500,
          ),
        ),
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: enabled ? const Color(0xFF1976D2) : Colors.grey.shade400,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        isExpanded: true,
        onChanged: enabled ? onChanged : null,
        items: items.map<DropdownMenuItem<String>>((item) {
          return DropdownMenuItem<String>(
            value: item.toString(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(item.toString()),
            ),
          );
        }).toList(),
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

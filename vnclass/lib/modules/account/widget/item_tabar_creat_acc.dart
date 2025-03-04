import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/main_home/controller/year_provider.dart';

class ItemTabarCreatAcc extends StatefulWidget {
  final bool show;
  final String typeAcc;
  final bool? student;
  const ItemTabarCreatAcc({
    super.key,
    required this.show,
    required this.typeAcc,
    this.student,
  });

  @override
  State<ItemTabarCreatAcc> createState() => _ItemTabarCreatAccState();
}

class _ItemTabarCreatAccState extends State<ItemTabarCreatAcc> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneParentController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isShowPass = false;
  bool _isShowPassAgain = false;

  String selectedClass = '10A1';
  final List<String> classOptions = [
    '10A1',
    '10A2',
    '10A3',
    '11A1',
    '11A2',
    '11A3',
    '12A1',
    '12A2',
    '12A3'
  ];

  final ScrollController _scrollController = ScrollController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF263238),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  void onToggleShowPass() => setState(() => _isShowPass = !_isShowPass);
  void onToggleShowPassAgain() =>
      setState(() => _isShowPassAgain = !_isShowPassAgain);

  String? selectedValue;
  String selectedYear = '2024-2025';
  String selectedGender = 'Nam';

  @override
  void initState() {
    super.initState();
    selectedValue = widget.typeAcc;
    _usernameController.text = _employeeCodeController.text;
    _passwordController.text = '123';
    _confirmPasswordController.text = '123';
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _scrollToField(_passwordFocusNode);
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
        _scrollToField(_confirmPasswordFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _scrollToField(FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      _scrollController.animateTo(
        position.dy - keyboardHeight + 50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Map<String, String> _getFormData() {
    String type = '';
    if (widget.typeAcc == 'Học sinh') {
      type = 'hocSinh';
    } else if (widget.typeAcc == 'Giáo viên') {
      type = 'giaoVien';
    } else if (widget.typeAcc == 'Ban giám hiệu') {
      type = 'banGH';
    }
    return {
      'username': _nameController.text.trim(),
      'employeeCode': _employeeCodeController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'phoneParent': _phoneParentController.text.trim(),
      'password': _passwordController.text.trim(),
      'confirmPassword': _confirmPasswordController.text.trim(),
      'gender': selectedGender,
      'position': type,
      'date': _dateController.text.trim(),
      'class': selectedClass,
      'year': selectedYear,
    };
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _createAccount(String typeAcc) async {
    final formData = _getFormData();
    Map<String, Set<String>> monthData = {
      'month1': {'100', 'Tốt'},
      'month2': {'100', 'Tốt'},
      'month3': {'100', 'Tốt'},
      'month4': {'100', 'Tốt'},
      'month5': {'100', 'Tốt'},
      'month6': {'100', 'Tốt'},
      'month7': {'100', 'Tốt'},
      'month8': {'100', 'Tốt'},
      'month9': {'100', 'Tốt'},
      'month10': {'100', 'Tốt'},
      'month11': {'100', 'Tốt'},
      'month12': {'100', 'Tốt'},
    };
    List<Map<String, dynamic>> teacherUp = [];
    List<Map<String, dynamic>> accountStudentUp = [];
    List<Map<String, dynamic>> studentUp = [];
    List<Map<String, dynamic>> studentDetailsUp = [];
    List<Map<String, dynamic>> accountParentUp = [];
    List<Map<String, dynamic>> parentUp = [];
    List<Map<String, dynamic>> conductMonthUp = [];

    String username = formData['username'] ?? '';
    String employeeCode = formData['employeeCode'] ?? '';
    String email = formData['email'] ?? '';
    String phone = formData['phone'] ?? '';
    String phoneParent = formData['phoneParent'] ?? '';
    String password = formData['password'] ?? '';
    String gender = formData['gender'] ?? '';
    String position = formData['position'] ?? '';
    String date = formData['date'] ?? '';
    String classs = formData['class'] ?? '';
    String year = formData['year'] ?? '';

    List<String> init = [];

    try {
      if (position == 'banGH' || position == 'giaoVien') {
        accountStudentUp.add({
          '_accName': username,
          '_birth': date,
          '_email': email,
          '_gender': gender,
          '_groupID': position,
          '_id': employeeCode,
          '_pass': _hashPassword('123'),
          '_permission': init,
          '_phone': phone,
          '_status': 'true',
          '_token': init,
          '_userName': employeeCode,
        });

        teacherUp.add({
          '_id': employeeCode,
          'ACC_id': employeeCode,
          '_birthday': date,
          '_gender': gender,
          '_phone': phone,
          '_teacherName': username,
        });

        await Future.wait([
          Future.wait(teacherUp.map((teacher) {
            String docId = teacher['_id'];
            return FirebaseFirestore.instance
                .collection('TEACHER')
                .doc(docId)
                .set(teacher);
          })),
          Future.wait(accountStudentUp.map((studentup) {
            String docId = studentup['_id'];
            return FirebaseFirestore.instance
                .collection('ACCOUNT')
                .doc(docId)
                .set(studentup);
          })),
        ]);
      } else if (position == 'hocSinh') {
        accountStudentUp.add({
          '_accName': username,
          '_birth': date,
          '_email': email,
          '_gender': gender,
          '_groupID': position,
          '_id': employeeCode,
          '_pass': _hashPassword('123'),
          '_permission': init,
          '_phone': phone,
          '_status': 'true',
          '_token': init,
          '_userName': employeeCode,
        });

        accountParentUp.add({
          '_accName': 'PHHS - $username - $employeeCode',
          '_birth': '',
          '_email': '',
          '_gender': '',
          '_groupID': 'phuHuynh',
          '_id': phoneParent,
          '_pass': _hashPassword('123'),
          '_permission': init,
          '_phone': phoneParent,
          '_status': 'true',
          '_token': init,
          '_userName': phoneParent,
        });

        conductMonthUp.add({
          'STDL_id': employeeCode,
          '_id': '$employeeCode$year',
          '_month': monthData,
        });

        parentUp.add({
          'ACC_id': phoneParent,
          '_birthday': '',
          '_gender': '',
          '_id': phoneParent,
          '_parentName': 'PHHS - $username - $employeeCode',
          '_phone': phoneParent,
        });

        studentUp.add({
          '_id': employeeCode,
          'ACC_id': employeeCode,
          'P_id': phoneParent,
          '_birthday': date,
          '_gender': gender,
          '_phone': phone,
          '_studentName': username,
        });

        studentDetailsUp.add({
          'Class_id': '${classs.toLowerCase()}$year',
          'Class_name': classs.toLowerCase(),
          'ST_id': employeeCode,
          '_birthday': date,
          '_committee': 'Học sinh',
          '_conductAllYear': 'Tốt',
          '_conductTerm1': 'Tốt',
          '_conductTerm2': 'Tốt',
          '_gender': gender,
          '_id': '$employeeCode$year',
          '_phone': phone,
          '_studentName': username,
        });

        // Tăng _amount trong CLASS
        CollectionReference classCollection =
            FirebaseFirestore.instance.collection('CLASS');
        DocumentReference classDoc =
            classCollection.doc('${classs.toLowerCase()}$year');
        await classDoc.get().then((snapshot) async {
          if (snapshot.exists) {
            // Ép kiểu dữ liệu từ snapshot.data() thành Map<String, dynamic>
            final data = snapshot.data() as Map<String, dynamic>;
            final currentAmount = data['_amount'] as num? ?? 0;
            final newAmount = currentAmount.toInt() + 1;
            await classDoc.update({'_amount': newAmount});
          } else {
            // Tạo mới tài liệu CLASS nếu chưa tồn tại
            await classDoc.set({
              '_id': '${classs.toLowerCase()}$year',
              '_amount': 1,
              // Thêm các trường khác nếu cần
            });
          }
        }).catchError((error) {
          print(
              'Error accessing document ${classs.toLowerCase()}$year: $error');
        });

        await Future.wait([
          Future.wait(studentUp.map((studentup) {
            String docId = studentup['_id'];
            return FirebaseFirestore.instance
                .collection('STUDENT')
                .doc(docId)
                .set(studentup);
          })),
          Future.wait(studentDetailsUp.map((studentup) {
            String docId = studentup['_id'];
            return FirebaseFirestore.instance
                .collection('STUDENT_DETAIL')
                .doc(docId)
                .set(studentup);
          })),
          Future.wait(conductMonthUp.map((studentup) {
            String docId = studentup['_id'];
            return FirebaseFirestore.instance
                .collection('CONDUCT_MONTH')
                .doc(docId)
                .set(studentup);
          })),
          Future.wait(accountStudentUp.map((studentup) {
            String docId = studentup['_id'];
            return FirebaseFirestore.instance
                .collection('ACCOUNT')
                .doc(docId)
                .set(studentup);
          })),
          Future.wait(accountParentUp.map((studentup) {
            String docId = studentup['_id'];
            return FirebaseFirestore.instance
                .collection('ACCOUNT')
                .doc(docId)
                .set(studentup);
          })),
          Future.wait(parentUp.map((studentup) {
            String docId = studentup['_id'];
            return FirebaseFirestore.instance
                .collection('PARENT')
                .doc(docId)
                .set(studentup);
          })),
        ]);
      }

      print('Dữ liệu lưu: $formData');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo tài khoản thành công!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Lỗi khi tạo tài khoản: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo tài khoản thất bại!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    final years = yearProvider.years;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.show) ...[
            _buildSectionHeader('Thông tin lớp học'),
            DropMenuWidget(
              items: classOptions,
              hintText: 'Lớp',
              selectedItem: selectedClass,
              onChanged: (newValue) =>
                  setState(() => selectedClass = newValue!),
              fillColor: Colors.white,
              borderColor: const Color(0xFFE0E0E0),
              textStyle: theme.textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF263238)),
            ),
            const SizedBox(height: 16),
            DropMenuWidget(
              items: years,
              hintText: 'Năm học',
              selectedItem: selectedYear,
              onChanged: (newValue) => setState(() => selectedYear = newValue!),
              fillColor: Colors.white,
              borderColor: const Color(0xFFE0E0E0),
              textStyle: theme.textTheme.bodyMedium
                  ?.copyWith(color: const Color(0xFF263238)),
            ),
            const SizedBox(height: 24),
          ],
          _buildSectionHeader('Thông tin cá nhân'),
          TextfieldWidget(
            labelText: 'Tên người dùng',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          TextfieldWidget(
            labelText: 'Mã viên chức',
            controller: _employeeCodeController,
          ),
          const SizedBox(height: 16),
          TextfieldWidget(
            labelText: 'Email',
            controller: _emailController,
          ),
          const SizedBox(height: 16),
          TextfieldWidget(
            labelText: 'SĐT',
            controller: _phoneController,
          ),
          if (widget.typeAcc == 'Học sinh') ...[
            const SizedBox(height: 16),
            TextfieldWidget(
              labelText: 'SĐT PHHS',
              controller: _phoneParentController,
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _dateController,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: const Color(0xFF263238)),
            decoration: InputDecoration(
              labelText: 'Ngày sinh',
              labelStyle: const TextStyle(color: Color(0xFF78909C)),
              fillColor: Colors.white,
              filled: true,
              suffixIcon: IconButton(
                icon: const Icon(FontAwesomeIcons.calendar,
                    color: Color(0xFF1976D2), size: 20),
                onPressed: _selectDate,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1976D2), width: 2),
              ),
            ),
            readOnly: true,
            onTap: _selectDate,
          ),
          const SizedBox(height: 16),
          _buildRadioSection('Giới tính', ['Nam', 'Nữ'], selectedGender,
              (value) => setState(() => selectedGender = value!)),
          const SizedBox(height: 24),
          _buildSectionHeader('Thông tin tài khoản'),
          _buildRadioSection(
              'Chức vụ', [widget.typeAcc], widget.typeAcc, (value) {},
              enabled: false),
          const SizedBox(height: 16),
          TextfieldWidget(
            labelText: 'Tên tài khoản',
            controller: _employeeCodeController,
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildPasswordField('Mật khẩu', _passwordController, _isShowPass,
              onToggleShowPass, false,
              focusNode: _passwordFocusNode),
          const SizedBox(height: 16),
          _buildPasswordField('Nhập lại mật khẩu', _confirmPasswordController,
              _isShowPassAgain, onToggleShowPassAgain, false,
              focusNode: _confirmPasswordFocusNode),
          if (widget.typeAcc == 'Học sinh') ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Thông tin tài khoản PHHS'),
            _buildRadioSection(
                'Chức vụ', ['Phụ huynh'], 'Phụ huynh', (value) {},
                enabled: false),
            const SizedBox(height: 16),
            TextfieldWidget(
              labelText: 'Tên tài khoản',
              controller: _phoneParentController,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildPasswordField('Mật khẩu', _passwordController, _isShowPass,
                onToggleShowPass, false,
                focusNode: _passwordFocusNode),
            const SizedBox(height: 16),
            _buildPasswordField('Nhập lại mật khẩu', _confirmPasswordController,
                _isShowPassAgain, onToggleShowPassAgain, false,
                focusNode: _confirmPasswordFocusNode),
          ],
          const SizedBox(height: 32),
          ButtonWidget(
            title: 'Tạo tài khoản',
            color: const Color(0xFF1976D2),
            ontap: () => _createAccount(widget.typeAcc),
          ),
          const SizedBox(height: 160),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF455A64),
        ),
      ),
    );
  }

  Widget _buildRadioSection(String label, List<String> options,
      String selectedValue, ValueChanged<String?>? onChanged,
      {bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF78909C),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RadioButtonWidget(
              options: options,
              onChanged: enabled
                  ? onChanged ?? (String? value) {}
                  : (String? value) {},
              selectedValue: selectedValue,
              layout: RadioLayout.horizontal,
              activeColor: const Color(0xFF1976D2),
              labelStyle:
                  const TextStyle(fontSize: 16, color: Color(0xFF263238)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    VoidCallback onToggle,
    bool enabled, {
    required FocusNode focusNode,
  }) {
    return TextField(
      enabled: enabled,
      obscureText: isVisible,
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(
        fontSize: 16,
        color: enabled ? const Color(0xFF263238) : Colors.grey.shade400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF78909C) : Colors.grey.shade400,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: enabled ? const Color(0xFF1976D2) : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
            size: 20,
            color: enabled ? const Color(0xFF1976D2) : Colors.grey.shade400,
          ),
          onPressed: enabled ? onToggle : null,
        ),
      ),
    );
  }
}

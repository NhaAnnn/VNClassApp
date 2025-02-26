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
  final bool show; // Hiển thị phần lớp và năm học nếu true
  final String typeAcc; // Loại tài khoản
  final bool? student; // Là học sinh hay không
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

  String selectedClass = '10A1'; // Giá trị mặc định cho lớp
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
  ]; // Danh sách lớp mẫu

  // Thêm ScrollController để điều khiển cuộn
  final ScrollController _scrollController = ScrollController();
  // Thêm FocusNode cho các trường nhập liệu để theo dõi focus
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

    // Lắng nghe sự kiện focus để cuộn tới trường đang nhập
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

  // Hàm cuộn tới trường đang focus
  void _scrollToField(FocusNode focusNode) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      _scrollController.animateTo(
        position.dy -
            keyboardHeight +
            50, // Cuộn lên trên bàn phím với khoảng cách 50px
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
      'username': _usernameController.text.trim(),
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
    // Logique de création de compte reste inchangée
    // (Giữ nguyên logic của bạn ở đây)
  }

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    final years = yearProvider.years;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      controller: _scrollController, // Gắn ScrollController
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phần 1: Thông tin lớp học (nếu hiển thị)
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

          // Phần 2: Thông tin cá nhân
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
          if (widget.student ?? true) ...[
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

          // Phần 3: Thông tin tài khoản
          const SizedBox(height: 24),
          _buildSectionHeader('Thông tin tài khoản'),
          _buildRadioSection(
              'Chức vụ', [widget.typeAcc], widget.typeAcc, (value) {},
              enabled: false),
          const SizedBox(height: 16),
          TextfieldWidget(
            labelText: 'Tên tài khoản',
            controller: _usernameController,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
              'Mật khẩu', _passwordController, _isShowPass, onToggleShowPass,
              focusNode: _passwordFocusNode),
          const SizedBox(height: 16),
          _buildPasswordField('Nhập lại mật khẩu', _confirmPasswordController,
              _isShowPassAgain, onToggleShowPassAgain,
              focusNode: _confirmPasswordFocusNode),

          // Nút Tạo tài khoản
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

  // Hàm tạo tiêu đề phần
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

  // Hàm tạo phần radio
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

  // Hàm tạo trường mật khẩu với FocusNode
  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isVisible, VoidCallback onToggle,
      {required FocusNode focusNode}) {
    return TextField(
      obscureText: !isVisible,
      controller: controller,
      focusNode: focusNode, // Gắn FocusNode để theo dõi focus
      style: const TextStyle(fontSize: 16, color: Color(0xFF263238)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF78909C)),
        filled: true,
        fillColor: Colors.white,
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
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
            size: 20,
            color: const Color(0xFF1976D2),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

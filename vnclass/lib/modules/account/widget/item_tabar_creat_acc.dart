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
  final bool show; // Thêm biến show để kiểm soát hiển thị
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
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _phoneParentController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isShowPass = false;
  bool _isShowPassAgain = false;

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

  String? selectedValue;
  String selectedYear = '2024-2025';
  @override
  void initState() {
    super.initState();
    selectedValue = widget.typeAcc;
  }

  String selectedGender = 'Nam'; // Biến để lưu giá trị đã chọn

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
      'class': _classController.text.trim(),
      'year': selectedYear ?? '',
    };
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _createAccount(String typeAcc) async {
    final formData = _getFormData();

    if (typeAcc == 'Học sinh') {
      String birth = formData['date'] ?? '';
      String ddmm = '';

      if (birth.length >= 10) {
        // Lấy 2 ký tự đầu cho ngày và tháng
        ddmm = birth.substring(0, 2) + birth.substring(3, 5); // Lấy dd và mm
      }

      // Tạo 3 chữ số ngẫu nhiên
      Random random = Random();
      String xxx = random
          .nextInt(1000)
          .toString()
          .padLeft(3, '0'); // Đảm bảo là 3 chữ số

      // Kết hợp để tạo ID
      String id = 'H$ddmm$xxx';
      String phoneParent = formData['phoneParent'] ?? '';

      await FirebaseFirestore.instance.collection('ACCOUNT').doc(id).set({
        '_accName': formData['username'],
        '_birth': formData['date'],
        '_email': formData['email'],
        '_gender': formData['gender'], // Sửa thành _gender
        '_groupID': 'hocSinh', // Mã hóa mật khẩu nếu cần
        '_id': id, // Sửa thành _id
        '_pass': _hashPassword('123'), // Sửa thành _pass
        '_permission': [], // Khởi tạo _permission là một mảng rỗng
        '_phone': formData['phone'], // Sửa thành _phone
        '_status': 'true', // Sửa thành _status
        '_token': [], // Khởi tạo _token là một mảng rỗng
        '_userName': id, // Sửa thành _userName
      });

      // rele hocSinh
      await FirebaseFirestore.instance.collection('STUDENT').doc(id).set({
        'ACC_id': id,
        'P_id': phoneParent,
        '_birthday': formData['date'],
        '_gender': formData['gender'],
        '_id': id,
        '_phone': formData['phone'],
        '_studentName': formData['username'],
      });

      String classs = formData['class'] ?? '';
      String year = formData['year'] ?? '';
      String phone = formData['phone'] ?? '';
      String gender = formData['gender'] ?? '';
      String username = formData['username'] ?? '';
      await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .doc('$id$year')
          .set({
        'Class_id': '$classs$year',
        'Class_name': classs,
        'ST_id': id,
        '_birthday': formData['date'],
        '_committee': 'Học sinh',
        '_conductAllYear': 'Tốt',
        '_conductTerm1': 'Tốt',
        '_conductTerm2': 'Tốt',
        '_gender': formData['gender'],
        '_id': '$id$year',
        '_phone': phone,
        '_studentName': username,
      });

      await FirebaseFirestore.instance
          .collection('ACCOUNT')
          .doc(phoneParent)
          .set({
        '_accName': 'PHHS $username - $id',
        '_birth': '',
        '_email': formData['email'],
        '_gender': '', // Sửa thành _gender
        '_groupID': 'phuHuynh', // Mã hóa mật khẩu nếu cần
        '_id': phoneParent, // Sửa thành _id
        '_pass': _hashPassword('123'), // Sửa thành _pass
        '_permission': [], // Khởi tạo _permission là một mảng rỗng
        '_phone': formData['phone'], // Sửa thành _phone
        '_status': 'true', // Sửa thành _status
        '_token': [], // Khởi tạo _token là một mảng rỗng
        '_userName': phoneParent, // Sửa thành _userName
      });

      await FirebaseFirestore.instance
          .collection('PARENT')
          .doc(phoneParent)
          .set({
        'ACC_id': phoneParent,
        '_birthday': '',
        '_gender': '',
        '_id': phoneParent,
        '_parentName': 'PHHS $username - $id',
        '_phone': phoneParent,
      });

      // Khởi tạo Map cho _month
      Map<String, List<dynamic>> monthMap = {};

      for (int i = 1; i <= 12; i++) {
        monthMap['month$i'] = ['100', 'Tốt'];
      }

      await FirebaseFirestore.instance
          .collection('CONDUCT_MONTH')
          .doc('$id$year')
          .set({
        'STDL_id': '$id$year',
        '_id': '$id$year',
        '_month': monthMap,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tài khoản đã được tạo thành công!')),
      );
      Navigator.of(context).pop();
    } else {
      String classs = formData['class'] ?? '';
      String year = formData['year'] ?? '';
      String phone = formData['phone'] ?? '';
      String gender = formData['gender'] ?? '';
      String username = formData['username'] ?? '';
      String phoneParent = formData['phoneParent'] ?? '';
      String employeeCode = formData['employeeCode'] ?? '';
      await FirebaseFirestore.instance
          .collection('TEACHER')
          .doc(employeeCode)
          .set({
        'ACC_id': employeeCode,
        '_birthday': formData['date'],
        '_gender': gender,
        '_phone': phone,
        '_id': employeeCode,
        '_teacherName': username,
      });

      await FirebaseFirestore.instance
          .collection('ACCOUNT')
          .doc(employeeCode)
          .set({
        '_accName': formData['username'],
        '_birth': formData['date'],
        '_email': formData['email'],
        '_gender': gender, // Sửa thành _gender
        '_groupID': 'giaoVien', // Mã hóa mật khẩu nếu cần
        '_id': employeeCode, // Sửa thành _id
        '_pass': _hashPassword('123'), // Sửa thành _pass
        '_permission': [], // Khởi tạo _permission là một mảng rỗng
        '_phone': phone, // Sửa thành _phone
        '_status': 'true', // Sửa thành _status
        '_token': [], // Khởi tạo _token là một mảng rỗng
        '_userName': employeeCode, // Sửa thành _userName
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tài khoản đã được tạo thành công!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearProvider = Provider.of<YearProvider>(context);
    final years = yearProvider.years;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          // Hiển thị "Lớp" và "Năm học" chỉ nếu widget.show là true
          if (widget.show) ...[
            TextfieldWidget(
              labelText: 'Lớp',
              controller: _classController,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              children: [
                Text('Năm học:'),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Expanded(
                  child: DropMenuWidget(
                    items: years,
                    hintText: 'Năm học',
                    selectedItem: selectedYear,
                    onChanged: (newValue) {
                      setState(() {
                        selectedYear = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(
            labelText: 'Tên người dùng',
            controller: _nameController,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(
            labelText: 'Mã viên chức',
            controller: _employeeCodeController,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(
            labelText: 'Email',
            controller: _emailController,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(
            labelText: 'SĐT',
            controller: _phoneController,
          ),
          if (widget.student ?? true) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            TextfieldWidget(
              labelText: 'SĐT PHHS',
              controller: _phoneParentController,
            ),
          ],

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextField(
            controller: _dateController,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              labelText: 'Date',
              fillColor: Colors.white,
              suffixIcon: Icon(FontAwesomeIcons.calendar),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorApp.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
            readOnly: true,
            onTap: () {
              _selectDate();
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              Text('Giới tính:'),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              Expanded(
                  child: RadioButtonWidget(
                      options: ['Nam', 'Nữ'],
                      onChanged: (value) {
                        setState(() {
                          selectedGender =
                              value!; // Cập nhật giá trị khi người dùng chọn
                        });
                      })),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              Text('Chức vụ:'),
              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
              Expanded(
                child: RadioButtonWidget(
                  options: [widget.typeAcc],
                  onChanged: (value) {
                    // Xử lý giá trị khi thay đổi
                  },
                  selectedValue: widget.typeAcc, // Giá trị mặc định
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          TextfieldWidget(
            labelText: 'Tên tài khoản',
            controller: _usernameController,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    TextField(
                      obscureText: !_isShowPass,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        labelStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: ColorApp.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 29, 92, 252),
                              width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorApp.primaryColor, width: 2.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: onToggleShowPass,
                        child: Icon(
                          _isShowPass
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),

          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: AlignmentDirectional.centerEnd,
                  children: [
                    TextField(
                      obscureText: !_isShowPassAgain,
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Nhập lại mật khẩu',
                        labelStyle: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: ColorApp.primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color.fromARGB(255, 29, 92, 252),
                              width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: ColorApp.primaryColor, width: 2.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: GestureDetector(
                        onTap: onToggleShowPassAgain,
                        child: Icon(
                          _isShowPassAgain
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 20,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),

          Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  title: 'Tạo tài khoản',
                  ontap: () {
                    _createAccount(widget.typeAcc);
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
          ),
        ],
      ),
    );
  }
}

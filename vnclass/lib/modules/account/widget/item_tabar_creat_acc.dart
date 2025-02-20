import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/design/color.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/common/widget/radio_button_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';

class ItemTabarCreatAcc extends StatefulWidget {
  final bool show; // Thêm biến show để kiểm soát hiển thị

  const ItemTabarCreatAcc({super.key, required this.show});

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

  String? selectedValue = 'Ban giám hiệu'; // Giá trị mặc định
  String selectedGender = 'Nam'; // Biến để lưu giá trị đã chọn

  Map<String, String> _getFormData() {
    return {
      'username': _usernameController.text.trim(),
      'employeeCode': _employeeCodeController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text.trim(),
      'confirmPassword': _confirmPasswordController.text.trim(),
      'gender': selectedGender,
      'position': 'banGH',
      'date': _dateController.text.trim(),
    };
  }

  Future<void> _createAccount() async {
    final formData = _getFormData();
    // final errorMessage = _validateForm(formData);

    // if (errorMessage != null) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    //   return;
    // }

    // bool confirm = await CustomDialogWidget.showConfirmationDialog(
    //   context, 'Xác nhận tạo tài khoản?',
    // );

    if (true) {
      await FirebaseFirestore.instance.collection('ACCOUNT').doc('').set({
        '_accName': formData['username'],
        '_birth': formData['employeeCode'],
        '_email': formData['email'],
        '_gender': formData['gender'], // Sửa thành _gender
        '_groupID': formData['password'], // Mã hóa mật khẩu nếu cần
        '_id': formData['gender'], // Sửa thành _id
        '_pass': formData['date'], // Sửa thành _pass
        '_permission': [], // Khởi tạo _permission là một mảng rỗng
        '_phone': formData['phone'], // Sửa thành _phone
        '_status': formData['date'], // Sửa thành _status
        '_token': [], // Khởi tạo _token là một mảng rỗng
        '_userName': formData['username'], // Sửa thành _userName
      });

      await FirebaseFirestore.instance.collection('TEACHER').doc().set({
        'ACC_id': formData['username'],
        '_birthday': formData['employeeCode'],
        '_gender': formData['email'],
        '_id': formData['phone'],
        '_teacherName': formData['gender'],
      });

// rele hocSinh
      await FirebaseFirestore.instance.collection('STUDENT').doc('').set({
        'ACC_id': '',
        '_birthday': '',
        '_gender': '',
        '_id': '',
        '_phone': '',
        '_studentName': '',
      });
      await FirebaseFirestore.instance
          .collection('STUDENT_DETAIL')
          .doc('')
          .set({
        'Class_id': '',
        'Class_name': '',
        'ST_id': '',
        '_birthday': '',
        '_committee': '',
        '_conductAllYear': '',
        '_conductTerm1': '',
        '_conductTerm2': '',
        '_gender': '',
        '_id': '',
        '_phone': '',
        '_studentName': '',
      });
      await FirebaseFirestore.instance.collection('PARENT').doc('').set({
        'ACC_id': '',
        '_birthday': '',
        '_gender': '',
        '_id': '',
        '_parentName': '',
        '_phone': '',
      });

// Khởi tạo Map cho _month
      Map<String, List<dynamic>> monthMap = {};

      for (int i = 1; i <= 12; i++) {
        monthMap['month$i'] = ['100', 'Tốt'];
      }

      await FirebaseFirestore.instance
          .collection('CONDUCT_MONTH')
          .doc('0')
          .set({
        'STDL_id': '',
        '_id': '',
        '_gender': '',
        '_month': monthMap,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tài khoản đã được tạo thành công!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          // Hiển thị "Lớp" và "Năm học" chỉ nếu widget.show là true
          if (widget.show) ...[
            TextfieldWidget(labelText: 'Lớp'),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Row(
              children: [
                Text('Năm học:'),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Expanded(
                  child: DropMenuWidget(items: ['2024-2025']),
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
                  options: ['Ban giám hiệu'],
                  onChanged: (value) {
                    // Xử lý giá trị khi thay đổi
                  },
                  selectedValue: 'Ban giám hiệu', // Giá trị mặc định
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
                    _createAccount();
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

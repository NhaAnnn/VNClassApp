import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Nhớ import Firestore
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';

class UserDialogAddType extends StatefulWidget {
  const UserDialogAddType({super.key});

  @override
  _UserDialogAddTypeState createState() => _UserDialogAddTypeState();
}

class _UserDialogAddTypeState extends State<UserDialogAddType> {
  final TextEditingController _nameTypeController = TextEditingController();

  Future<void> _addTypeMistake() async {
    String nameMistakeType = _nameTypeController.text.trim();

    if (nameMistakeType.isEmpty) {
      // Xử lý nếu TextField trống
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên loại vi phạm')),
      );
      return;
    }

    // Lấy số lượng tài liệu hiện có
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('MISTAKE_TYPE').get();
    int docCount = snapshot.docs.length;

    // Tạo ID mới
    String newId = 'MT0${docCount + 1}';

    // Thêm tài liệu mới vào Firestore
    await FirebaseFirestore.instance.collection('MISTAKE_TYPE').doc(newId).set({
      '_id': newId,
      '_mistakeTypeName': nameMistakeType,
      '_status': true,
    });

    // Đóng dialog sau khi thêm thành công
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thành công')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chọn Thông Tin',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextfieldWidget(
                      labelText: 'Tên loại vi phạm',
                      controller:
                          _nameTypeController, // Gán controller vào TextField
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      title: 'Thêm',
                      ontap: () {
                        _addTypeMistake();
                      }, // Gọi hàm thêm khi nhấn nút
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ButtonWidget(
                      title: 'Thoát',
                      color: Colors.red,
                      ontap: () {
                        Navigator.of(context).pop(); // Đóng dialog
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

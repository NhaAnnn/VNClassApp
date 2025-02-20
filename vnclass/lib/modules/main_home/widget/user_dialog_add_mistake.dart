import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';

class UserDialogAddMistake extends StatefulWidget {
  const UserDialogAddMistake({
    super.key,
    this.showBtnDelete = true,
    this.mistakeDialog = false,
    this.mistake,
    this.typeItems,
    this.onUpdate,
  });

  final bool showBtnDelete;
  final bool mistakeDialog;
  final MistakeModel? mistake;
  final List<TypeMistakeModel>? typeItems;
  final VoidCallback? onUpdate;
  @override
  State<UserDialogAddMistake> createState() => _UserDialogAddMistakeState();
}

class _UserDialogAddMistakeState extends State<UserDialogAddMistake> {
  String? selectedOption;
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPoint = TextEditingController();

  @override
  void initState() {
    super.initState();

    selectedOption = widget.typeItems!.first.nameType;
  }

  Future<void> _addTypeMistake() async {
    String nameMistake = _controllerName.text.trim();
    int? minusPoint = int.tryParse(_controllerPoint.text);

    final selectedType = widget.typeItems!.firstWhere(
      (type) => type.nameType == selectedOption,
      orElse: () => TypeMistakeModel(idType: '', nameType: '', status: true),
    );

    if (nameMistake.isEmpty) {
      // Xử lý nếu TextField trống
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên loại vi phạm')),
      );
      return;
    }

    // Lấy số lượng tài liệu hiện có
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('MISTAKE').get();
    int docCount = snapshot.docs.length;

    // Tạo ID mới
    String newId = 'M0${docCount + 1}';

    // Thêm tài liệu mới vào Firestore
    await FirebaseFirestore.instance.collection('MISTAKE').doc(newId).set({
      '_id': newId,
      'MT_id': selectedType.idType,
      '_mistakeName': nameMistake,
      '_minusPoint': minusPoint,
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
              Row(
                children: [
                  Expanded(
                    child: DropMenuWidget(
                      items: widget.typeItems
                              ?.map((type) => type.nameType)
                              .toList() ??
                          [],
                      selectedItem: selectedOption,
                      onChanged: (value) {
                        setState(() {
                          selectedOption = value; // Update selected value
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextfieldWidget(
                      labelText: 'Nhập vi phạm',
                      controller: _controllerName,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                children: [
                  Expanded(
                    child: TextfieldWidget(
                      labelText: 'Điểm Trừ',
                      controller: _controllerPoint,
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
                      ontap: () async {
                        await _addTypeMistake(); // Call the update method
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ButtonWidget(
                      title: 'Thoát',
                      color: Colors.red,
                      ontap: () => Navigator.of(context).pop(),
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

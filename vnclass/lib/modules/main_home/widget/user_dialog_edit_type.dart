import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDialogEditType extends StatefulWidget {
  const UserDialogEditType({
    super.key,
    this.showBtnDelete = true,
    this.mistakeDialog = false,
    this.mistake,
    this.typeItems,
    this.onUpdate, // Add this line
  });

  final bool showBtnDelete;
  final bool mistakeDialog;
  final MistakeModel? mistake;
  final List<TypeMistakeModel>? typeItems;
  final VoidCallback? onUpdate; // Add this line for the callback

  @override
  State<UserDialogEditType> createState() => _UserDialogEditTypeState();
}

class _UserDialogEditTypeState extends State<UserDialogEditType> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPoint = TextEditingController();
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    _controllerName.text = widget.mistake?.nameMistake ?? '';
    _controllerPoint.text = widget.mistake?.minusPoint.toString() ?? '';

    if (widget.typeItems != null && widget.mistake != null) {
      final matchedType = widget.typeItems!.firstWhere(
        (type) => type.idType == widget.mistake!.mtID,
        orElse: () => TypeMistakeModel(
            idType: '', nameType: '', mistakes: [], status: false),
      );

      selectedOption =
          matchedType.nameType.isNotEmpty ? matchedType.nameType : null;
    }
  }

  Future<void> _updateMistake(bool status) async {
    if (widget.mistake == null || selectedOption == null) return;

    final selectedType = widget.typeItems!.firstWhere(
      (type) => type.nameType == selectedOption,
      orElse: () => TypeMistakeModel(idType: '', nameType: '', status: true),
    );

    final updatedMistake = MistakeModel(
      idMistake: widget.mistake!.idMistake,
      mtID: selectedType.idType,
      nameMistake: _controllerName.text,
      minusPoint: int.tryParse(_controllerPoint.text) ?? 0,
      status: status,
    );

    await FirebaseFirestore.instance
        .collection('MISTAKE')
        .doc(updatedMistake.idMistake)
        .update(updatedMistake.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cập nhật thành công!')),
    );

    // Call the onUpdate callback to reload data
    widget.onUpdate!();

    // Close the dialog
    Navigator.of(context).pop();
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
                      title: 'Chỉnh sửa',
                      ontap: () async {
                        await _updateMistake(true); // Call the update method
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
              if (widget.showBtnDelete) ...[
                Row(
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        title: 'Xóa Vi Phạm',
                        ontap: () async {
                          await _updateMistake(false);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/account/widget/textfield_widget.dart';
import 'package:vnclass/modules/mistake/models/mistake_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vnclass/common/widget/confirmation_dialog.dart'; // Import ConfirmationDialog

class UserDialogEditType extends StatefulWidget {
  const UserDialogEditType({
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

    try {
      await FirebaseFirestore.instance
          .collection('MISTAKE')
          .doc(updatedMistake.idMistake)
          .update(updatedMistake.toMap());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onUpdate?.call(); // Gọi callback để làm mới dữ liệu
      if (context.mounted) {
        Navigator.of(context).pop(); // Đóng dialog chỉnh sửa
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleDelete() {
    ConfirmationDialog.show(
      context: context,
      title: 'Xác nhận xóa',
      message:
          'Bạn có chắc chắn muốn xóa vi phạm "${widget.mistake?.nameMistake}" không?',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
    ).then((confirmed) {
      if (confirmed == true) {
        _updateMistake(false); // Gọi hàm cập nhật với status = false để xóa
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chỉnh Sửa Vi Phạm',
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
                          selectedOption = value;
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
                    child: ElevatedButton(
                      onPressed: () async {
                        await _updateMistake(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Màu nút chỉnh sửa
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Chỉnh sửa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        backgroundColor:
                            Colors.grey.shade100, // Màu nền nhẹ cho Thoát
                      ),
                      child: Text(
                        'Thoát',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              if (widget.showBtnDelete) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent, // Màu nút xóa
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Xóa Vi Phạm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/confirmation_dialog.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:vnclass/modules/main_home/widget/user_dialog_edit_type.dart';

class ItemTypeMistake extends StatefulWidget {
  const ItemTypeMistake({
    super.key,
    required this.controller,
  });

  final MistakeController controller;

  @override
  ItemTypeMistakeState createState() => ItemTypeMistakeState();
}

class ItemTypeMistakeState extends State<ItemTypeMistake> {
  List<TypeMistakeModel>? items;

  @override
  void initState() {
    super.initState();
    _loadMistakeTypes();
  }

  Future<void> _loadMistakeTypes() async {
    items = await widget.controller.fetchMistakeTypes();
    setState(() {});
  }

  Future<void> refreshData() async {
    await _loadMistakeTypes();
  }

  Future<void> _updateTypeMistake(
      TypeMistakeModel typeModel, bool status) async {
    final updatedMistake = TypeMistakeModel(
      idType: typeModel.idType,
      nameType: typeModel.nameType,
      status: status,
    );

    try {
      await FirebaseFirestore.instance
          .collection('MISTAKE_TYPE')
          .doc(updatedMistake.idType)
          .update(updatedMistake.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thành công!')),
      );

      await refreshData(); // Làm mới dữ liệu sau khi cập nhật
      // Xóa dòng Navigator.pop(context) để không thoát trang
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items!.length,
      itemBuilder: (context, index) {
        var item = items![index];
        return Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            leading: GestureDetector(
              onTap: () {
                ConfirmationDialog.show(
                  context: context,
                  title: 'Xác nhận xóa',
                  message:
                      'Bạn có chắc chắn muốn xóa loại vi phạm "${item.nameType}" không?',
                  confirmText: 'Xóa',
                  cancelText: 'Hủy',
                  confirmColor: Colors.redAccent,
                ).then((confirmed) {
                  if (confirmed == true) {
                    _updateTypeMistake(item, false);
                  }
                });
              },
              child: Icon(Icons.delete),
            ),
            title: Text(item.nameType),
            children: item.mistakes!.map((mistake) {
              return ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return UserDialogEditType(
                        mistake: mistake,
                        typeItems: items,
                        onUpdate: () async {
                          await refreshData();
                        },
                      );
                    },
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 8,
                      child: Text(mistake.nameMistake),
                    ),
                    Expanded(
                      flex: 2,
                      child: Icon(Icons.edit),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

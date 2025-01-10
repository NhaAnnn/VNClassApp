import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:vnclass/modules/main_home/widget/user_dialog_edit_type.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';

class ItemTypeMistake extends StatefulWidget {
  const ItemTypeMistake({
    super.key,
    required this.controller,
    this.onRefresh,
  });

  final MistakeController controller;
  final Future<void> Function()? onRefresh;

  // Phương thức tĩnh để load lại dữ liệu

  @override
  _ItemTypeMistakeState createState() => _ItemTypeMistakeState();
}

class _ItemTypeMistakeState extends State<ItemTypeMistake> {
  List<TypeMistakeModel>? items;

  @override
  void initState() {
    super.initState();
    _loadMistakeTypes();
  }

  Future<void> _loadMistakeTypes() async {
    items = await widget.controller.fetchMistakeTypes();
    setState(() {}); // Update the UI once data is loaded
  }

  // Phương thức công khai để tải lại dữ liệu
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

    await FirebaseFirestore.instance
        .collection('MISTAKE_TYPE')
        .doc(updatedMistake.idType)
        .update(updatedMistake.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cập nhật thành công!')),
    );

    // Call the onUpdate callback to reload data
    _loadMistakeTypes();

    // Close the dialog
    Navigator.of(context).pop();
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
              onTap: () => CustomDialogWidget.showConfirmationDialog(
                  context, 'title', onTapOK: () {
                _updateTypeMistake(item, false);
              }),
              child: Icon(FontAwesomeIcons.trash),
            ),
            title: Text(item.nameType),
            children: item.mistakes!.map((mistake) {
              return ListTile(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return UserDialogEditType(
                        mistake: mistake,
                        typeItems: items,
                        onUpdate: () {
                          _loadMistakeTypes();
                        },
                      );
                    },
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(mistake.nameMistake),
                    Icon(FontAwesomeIcons.pen),
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

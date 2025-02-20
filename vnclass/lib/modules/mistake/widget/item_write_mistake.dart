import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/login/controller/provider.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/package_data.dart';
import 'package:vnclass/modules/mistake/models/student_detail_model.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:vnclass/modules/main_home/widget/user_dialog_edit_type.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';

class ItemWriteMistake extends StatefulWidget {
  const ItemWriteMistake({
    super.key,
    required this.controller,
    this.studentDetailModel,
  });

  final MistakeController controller;
  final StudentDetailModel? studentDetailModel;

  @override
  ItemWriteMistakeState createState() => ItemWriteMistakeState();
}

class ItemWriteMistakeState extends State<ItemWriteMistake> {
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
      Navigator.of(context).pop(); // Đóng dialog
    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final account = accountProvider.account;

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
            title: Text(item.nameType),
            children: item.mistakes!.map((mistake) {
              return ListTile(
                onTap: () => Navigator.of(context).pushNamed(
                  MistakeWriteMistakePage.routeName,
                  arguments: PackageData(
                    agrReq: mistake.nameMistake,
                    agr2: mistake,
                    agr3: widget.studentDetailModel,
                    agr4: account,
                  ),
                ),
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

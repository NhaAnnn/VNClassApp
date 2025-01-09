import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/main_home/controller/controller_change_type_mistake_sreen.dart';
import 'package:vnclass/modules/mistake/models/type_mistake_model.dart';
import 'package:vnclass/modules/main_home/widget/user_dialog_edit_type.dart';
import 'package:vnclass/modules/mistake/view/mistake_write_mistake_page.dart';

class ItemTypeMistake extends StatelessWidget {
  const ItemTypeMistake({
    super.key,
    required this.controller,
  });

  final MistakeController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TypeMistakeModel>>(
      future: controller.fetchMistakeTypes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('Error loading mistake types: ${snapshot.error}'));
        }

        final items = snapshot.data!;

        return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            var item = items[index];

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExpansionTile(
                leading: Icon(FontAwesomeIcons.trash),
                title: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(item
                          .nameType), // Thay đổi để hiển thị tên loại vi phạm
                    ],
                  ),
                ),
                children: item.mistakes.map((mistake) {
                  return ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return UserDialogEditType(
                            mistake: mistake,
                          ); // Hiển thị hộp thoại chỉnh sửa
                        },
                      );
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(mistake.nameMistake), // Hiển thị tên vi phạm
                        Icon(FontAwesomeIcons.pen),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

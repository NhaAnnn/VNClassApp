import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/modules/main_home/widget/user_dialog_add_type.dart';
import 'package:vnclass/modules/main_home/widget/user_dialog_edit_type.dart';

class UserAddTypeMistakeScreen extends StatefulWidget {
  const UserAddTypeMistakeScreen({super.key});
  static const String routeName = 'user_add_type_mistake_screen';
  @override
  State<UserAddTypeMistakeScreen> createState() =>
      _UserAddTypeMistakeScreenState();
}

class _UserAddTypeMistakeScreenState extends State<UserAddTypeMistakeScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Thêm Loại và Vi Phạm',
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.04,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return UserDialogAddType();
                    });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withAlpha(50), // Border color
                    width: 2, // Border width
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Icon(FontAwesomeIcons.plus),
                    ),
                    Expanded(
                      flex: 7,
                      child: Text('Thêm loại vi phạm '),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.04,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return UserDialogEditType(
                        showBtnDelete: false,
                      );
                    });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black.withAlpha(50), // Border color
                    width: 2, // Border width
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Icon(FontAwesomeIcons.plus),
                    ),
                    Expanded(
                      flex: 7,
                      child: Text('Thêm vi phạm '),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

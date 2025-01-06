import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/main_home/views/user_add_type_mistake_screen.dart';
import 'package:vnclass/modules/mistake/widget/item_type_mistake.dart';

class UserChangeTypeMistakeScreen extends StatefulWidget {
  const UserChangeTypeMistakeScreen({super.key});
  static const String routeName = '/user_change_type_mistake_screen';
  @override
  State<UserChangeTypeMistakeScreen> createState() =>
      _UserChangeTypeMistakeScreenState();
}

class _UserChangeTypeMistakeScreenState
    extends State<UserChangeTypeMistakeScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      titleString: 'Tùy chỉnh vi phạm',
      implementLeading: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget(
                    title: 'Thêm vi phạm và loại vi phạm',
                    ontap: () => Navigator.of(context)
                        .pushNamed(UserAddTypeMistakeScreen.routeName),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Column(
              children: [
                ItemTypeMistake(
                  leading: Icon(
                    FontAwesomeIcons.trash,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

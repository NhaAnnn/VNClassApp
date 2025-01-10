import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/button_widget.dart';
import 'package:vnclass/modules/classes/view/all_classes.dart';
import 'package:vnclass/modules/classes/widget/create_one_class_dialog.dart';
import 'package:vnclass/modules/conduct/view/all_conduct.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(80.0),
        child: Column(
          children: [
            ButtonWidget(
                title: 'Lớp học',
                ontap: () =>
                    Navigator.of(context).pushNamed(AllClasses.routeName)),
            ButtonWidget(
                title: 'DRL',
                ontap: () =>
                    Navigator.of(context).pushNamed(AllConduct.routeName))
          ],
        ),
      ),
    );
  }
}

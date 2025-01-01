import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/classes/widget/all_classes_card.dart';

class AllClasses extends StatefulWidget {
  const AllClasses({super.key});
  static String routeName = 'all_classes';

  @override
  State<AllClasses> createState() => _AllClassesState();
}

class _AllClassesState extends State<AllClasses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            BackBar(
              title: 'Lop 12a1',
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: AllClassesCard(),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_add.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
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
              title: 'Lớp 12a1',
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ButtonAdd(
                            color: Colors.cyan.shade500,
                            size: Size(150, 50),
                            label: 'Thêm 1 lớp học',
                            icon: Icon(
                              FontAwesomeIcons.addressCard,
                              color: Colors.white,
                            ),
                          ),
                          ButtonAdd(
                            color: Colors.cyan.shade500,
                            size: Size(150, 50),
                            label: 'Thêm DS lớp học',
                            icon: Icon(
                              FontAwesomeIcons.addressCard,
                              color: Colors.white,
                            ),
                          ),
                        ]),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropMenuWidget(
                          items: ['Học kỳ 1', 'Học kỳ 2'],
                          hintText: 'Học kỳ',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: DropMenuWidget(
                          items: ['2023-2024'],
                          hintText: 'Năm học',
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SearchBar(
                      hintText: 'Search...',
                      leading: Icon(FontAwesomeIcons.searchengin),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        AllClassesCard(),
                        AllClassesCard(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

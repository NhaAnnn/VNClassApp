import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/drop_menu_widget.dart';
import 'package:vnclass/modules/conduct/widget/all_conduct_card.dart';

class AllConduct extends StatefulWidget {
  const AllConduct({super.key});
  static String routeName = 'all_conduct';

  @override
  State<AllConduct> createState() => _AllConductState();
}

class _AllConductState extends State<AllConduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: 'Danh sách các lớp',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
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
                          items: ['Học kỳ 1', 'Học kỳ 2'],
                          hintText: 'Tháng',
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                          AllConductCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

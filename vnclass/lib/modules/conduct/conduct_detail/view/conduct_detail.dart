import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/conduct/conduct_detail/widget/conduct_detail_card.dart';

class ConductDetail extends StatefulWidget {
  const ConductDetail({super.key});
  static String routeName = 'conduct_detail';

  @override
  State<ConductDetail> createState() => _ConductDetailState();
}

class _ConductDetailState extends State<ConductDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: 'Hạnh kiểm....',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'Danh sách lớp:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
                          ConductDetailCard(),
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

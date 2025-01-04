import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/app_bar.dart';
import 'package:vnclass/common/widget/custom_dialog_widget.dart';
import 'package:vnclass/modules/report/widget/dialog_report.dart';

class ReportMainPage extends StatefulWidget {
  const ReportMainPage({super.key});
  static const String routeName = 'report_main_page';
  @override
  State<ReportMainPage> createState() => _ReportMainPageState();
}

class _ReportMainPageState extends State<ReportMainPage> {
  @override
  Widget build(BuildContext context) {
    return AppBarWidget(
      implementLeading: true,
      titleString: 'Báo Cáo',
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DialogReport();
                  },
                );
              },
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                    color: Colors.amber, // Container cha màu đỏ
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30), // Màu bóng
                        spreadRadius: 4, // Độ lan tỏa của bóng
                        blurRadius: 7, // Độ mờ của bóng
                        offset: Offset(0, 3),
                      )
                    ] // Bo tròn góc của Container cha
                    ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Icon(
                        Icons.download,
                        size: 60,
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Text(
                        'Xuất Báo Cáo Vi Phạm Lớp Học',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                  color: Colors.amber, // Container cha màu đỏ
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30), // Màu bóng
                      spreadRadius: 4, // Độ lan tỏa của bóng
                      blurRadius: 7, // Độ mờ của bóng
                      offset: Offset(0, 3),
                    )
                  ] // Bo tròn góc của Container cha
                  ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Icon(
                      Icons.download,
                      size: 60,
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Text(
                      'Xuất Báo Cáo Vi Phạm Trường Học',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

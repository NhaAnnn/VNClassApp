import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/search_bar.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/widget/conduct_detail_card.dart';
import 'package:vnclass/modules/search/search_screen.dart';

class ConductDetail extends StatefulWidget {
  const ConductDetail({super.key});
  static String routeName = 'conduct_detail';

  @override
  State<ConductDetail> createState() => _ConductDetailState();
}

class _ConductDetailState extends State<ConductDetail> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final classID = args['classID'];
    final className = args['className'];
    final monthKey = args['monthKey'] as int;

    String month;
    if (monthKey == 100) {
      month = 'Học kì 1';
    } else if (monthKey == 200) {
      month = 'Học kì 2';
    } else if (monthKey == 300) {
      month = 'Cả năm';
    } else {
      month = Getmonthnow.getMonthName(monthKey);
    }
    double paddingValue = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(
            title: 'Hạnh kiểm lớp $className $month',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(paddingValue * 0.02),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(paddingValue * 0.02),
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
                    padding: EdgeInsets.all(paddingValue * 0.02),
                    child: CustomSearchBar(
                      hintText: 'Search...',
                      onTap: () {
                        Navigator.pushNamed(context, SearchScreen.routeName);
                      },
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<StudentDetailModel>>(
                      future:
                          StudentDetailController.fetchStudentsByClass(classID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SkeletonLoader(
                            builder: Column(
                              children: List.generate(
                                2, // Số lượng skeleton items
                                (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            items: 1,
                            // period: const Duration(seconds: 2),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Không có học sinh'));
                        }

                        List<StudentDetailModel> students = snapshot.data!;
                        return ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            return ConductDetailCard(
                              studentModel: students[index],
                              monthKey: monthKey,
                            );
                          },
                        );
                      },
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

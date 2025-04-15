import 'package:flutter/material.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/controller/conduct_month_controller.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/model/conduct_month_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/widget/student_conduct_month_card.dart';
import 'package:vnclass/web/conduct/widget/conduct_student_month.dart';

class ConductStudentTerm extends StatefulWidget {
  const ConductStudentTerm({
    super.key,
    this.conduct,
    this.term,
    this.studentDetailModel,
  });

  static String routeName = 'conduct_student_term';

  final StudentDetailModel? studentDetailModel;
  final String? conduct;
  final int? term;

  @override
  State<ConductStudentTerm> createState() => _ConductStudentTermState();
}

class _ConductStudentTermState extends State<ConductStudentTerm> {
  StudentDetailModel? studentDetailModel;
  String? conduct;
  String? trainingScore;
  String? monthKey;

  String getTermString(int term) {
    if (term == 100) {
      return 'Học kì 1';
    } else if (term == 200) {
      return 'Học kì 2';
    } else {
      return 'Cả năm';
    }
  }

  @override
  Widget build(BuildContext context) {
    studentDetailModel = widget.studentDetailModel;
    conduct = widget.conduct;
    int term = widget.term!;

    // Check for null values
    if (studentDetailModel == null || conduct == null) {
      print('Student Detail Model: $studentDetailModel');
      print('Conduct: $conduct');
      print('Term: $term');
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(
            title: 'Hạnh kiểm của ${studentDetailModel!.studentName}',
            backgroundColor: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.only(top: 15.0, right: 15, left: 15),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 1),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF003B6F),
                          Color.fromARGB(255, 0, 166, 255)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Thông tin:',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin:
                      const EdgeInsets.only(bottom: 15.0, right: 15, left: 15),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildStudentInfoRow('Họ và tên: ',
                                studentDetailModel!.studentName.toString()),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow('Lớp: ',
                                studentDetailModel!.className.toString()),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow('Giới tính: ',
                                studentDetailModel!.gender.toString()),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow(
                                'Học kì: ', getTermString(term)),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow(
                                'Hạnh kiểm: ', conduct.toString()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FutureBuilder<ConductMonthModel>(
                      future: ConductMonthController.fetchConductMonth(
                          studentDetailModel!.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Lỗi: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.months!.isEmpty) {
                          return Center(child: Text('Không có dữ liệu.'));
                        }

                        ConductMonthModel conductMonthData = snapshot.data!;
                        var entries = conductMonthData.months!.entries.toList();

                        List<MapEntry<String, List<dynamic>>> data;

                        if (term == 100) {
                          data = entries.length > 4
                              ? entries.sublist(entries.length - 4)
                              : entries;
                        } else if (term == 200) {
                          data = entries.take(5).toList();
                        } else {
                          data = entries;
                        }
                        return SingleChildScrollView(
                          child: Wrap(
                            spacing: 16.0,
                            runSpacing: 16.0,
                            children: data.map((entry) {
                              final month = entry.key;
                              List<dynamic> details = entry.value;
                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.19,
                                child: StudentConductMonthCard(
                                  studentID: studentDetailModel!.id,
                                  studentName: studentDetailModel!.studentName!,
                                  month: month,
                                  trainingScore: details[0],
                                  conduct: details[1],
                                  onSelect: (conductData, trainingScoreData,
                                      monthData) {
                                    setState(() {
                                      conduct = conductData;
                                      trainingScore = trainingScoreData;
                                      monthKey = monthData;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 1,
        child: ConductStudentMonth(
          studentDetailModel: studentDetailModel,
          monthKey:
              monthKey != null ? Getmonthnow.getMonthNumber(monthKey!) : null,
          trainingScore: trainingScore,
          conduct: conduct,
        ),
      ),
    );
  }

  Widget _buildStudentInfoRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 81, 151),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

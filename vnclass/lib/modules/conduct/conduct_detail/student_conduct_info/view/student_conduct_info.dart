import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/controller/conduct_month_controller.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/model/conduct_month_model.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/widget/student_conduct_month_card.dart';

import '../../../../login/controller/provider.dart';

class StudentConductInfo extends StatefulWidget {
  const StudentConductInfo({super.key});
  static String routeName = 'student_conduct_info';

  @override
  State<StudentConductInfo> createState() => _StudentConductInfoState();
}

class _StudentConductInfoState extends State<StudentConductInfo> {
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
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    accountProvider.account;

    // Truy cập các tham số
    final studentID = args['studentID'];
    final studentName = args['studentName'];
    final conduct = args['conduct'];
    final term = args['term'] as int;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(title: 'Hạnh kiểm của $studentName'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Thông tin học sinh:',
                    style: TextStyle(fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.blue.shade100),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            _buildStudentInfoRow(
                                'Họ và tên:', studentName.toString()),
                            _buildStudentInfoRow(
                                'Học kì:', getTermString(term)),
                            _buildStudentInfoRow(
                                'Hạnh kiểm:', conduct.toString()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<ConductMonthModel>(
                      future:
                          ConductMonthController.fetchConductMonth(studentID),
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

                        // Xử lý theo điều kiện term
                        List<MapEntry<String, List<dynamic>>> data;

                        if (accountProvider.account!.goupID
                                .contains('hocSinh') ||
                            accountProvider.account!.goupID
                                .contains('phuHuynh')) {
                          data = entries;
                        } else {
                          if (term == 100) {
                            // Lấy 4 tháng cuối
                            data = entries.length > 4
                                ? entries.sublist(entries.length - 4)
                                : entries;
                          } else if (term == 200) {
                            // Lấy 5 tháng đầu
                            data = entries.take(5).toList();
                          } else {
                            // Lấy tất cả các tháng còn lại
                            data = entries;
                          }
                        }

                        return SingleChildScrollView(
                          child: Column(
                            children: data.map((entry) {
                              String month = entry.key;
                              List<dynamic> details = entry.value;

                              return StudentConductMonthCard(
                                studentID: studentID,
                                studentName: studentName,
                                month: month,
                                trainingScore: details[0],
                                conduct: details[1],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStudentInfoRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

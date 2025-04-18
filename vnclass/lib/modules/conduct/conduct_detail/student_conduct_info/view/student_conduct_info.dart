import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';

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
  String? conduct;
  String? conduct1;
  String? conduct2;
  String? conduct3;
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

    // Truy cập các tham số

    final studentModel = args['studentModel'] as StudentDetailModel;

    if (accountProvider.account!.goupID.contains('hocSinh') ||
        accountProvider.account!.goupID.contains('phuHuynh')) {
      conduct1 = args['conduct1'];
      conduct2 = args['conduct2'];
      conduct3 = args['conduct3'];
    } else {
      conduct = args['conduct'];
    }

    final term = args['term'] as int;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(title: 'Hạnh kiểm của ${studentModel.studentName}'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Thông tin học sinh:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.blue.shade100,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromARGB(
                              255, 72, 195, 252), // Xanh Lam (Light Blue)
                          Color.fromARGB(255, 6, 240, 217), // Xanh Lục (Teal)
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          _buildStudentInfoRow('Họ và tên:',
                              studentModel.studentName.toString()),
                          if (accountProvider.account!.goupID == 'hocSinh' ||
                              accountProvider.account!.goupID ==
                                  'phuHuynh') ...[
                            _buildStudentInfoRow(
                              'Lớp:',
                              studentModel.className.toString(),
                            ),
                            _buildStudentInfoRow(
                                'Hạnh kiểm HK1:', conduct1.toString()),
                            _buildStudentInfoRow(
                                'Hạnh kiểm HK2:', conduct2.toString()),
                            _buildStudentInfoRow(
                                'Hạnh kiểm CN:', conduct3.toString()),
                          ] else ...[
                            _buildStudentInfoRow(
                                'Học kì:', getTermString(term)),
                            _buildStudentInfoRow(
                                'Hạnh kiểm:', conduct.toString()),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                  Expanded(
                    child: FutureBuilder<ConductMonthModel>(
                      future: ConductMonthController.fetchConductMonth(
                          studentModel.id!),
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
                                studentID: studentModel.id!,
                                studentName: studentModel.studentName!,
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
        padding: const EdgeInsets.all(5),
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

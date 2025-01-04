import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/widget/student_mistake_card.dart';

class StudentConductInfo extends StatefulWidget {
  const StudentConductInfo({super.key});
  static String routeName = 'student_conduct_info';

  @override
  State<StudentConductInfo> createState() => _StudentConductInfoState();
}

class _StudentConductInfoState extends State<StudentConductInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(title: 'Hạnh kiểm của.......'),
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
                                'Họ và tên:', 'ỳgiysddiushsifdsi'),
                            _buildStudentInfoRow('Điểm rèn luyện:', '1231'),
                            _buildStudentInfoRow(
                                'Hạnh kiểm:', 'ídjbsdufnskdnídjbsdufn'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(10),
                        topEnd: Radius.circular(10),
                      ),
                      color: Colors.blue.shade100,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'STT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Vi phạm',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Chi tiết',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                          StudentMistakeCard(),
                        ],
                      ),
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

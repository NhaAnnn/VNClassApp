import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/widget/student_mistake_card.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';

class StudentConductInfoMonth extends StatefulWidget {
  const StudentConductInfoMonth({super.key});
  static String routeName = 'student_conduct_info_month';

  @override
  State<StudentConductInfoMonth> createState() =>
      _StudentConductInfoMonthState();
}

class _StudentConductInfoMonthState extends State<StudentConductInfoMonth> {
  List<EditMistakeModel> listMistake = [];

  Future<List<EditMistakeModel>> getMistake(
      String studentID, String month) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('MISTAKE_MONTH')
        .where('STD_id', isEqualTo: studentID)
        .where('_month', isEqualTo: month)
        .get();

    List<EditMistakeModel> mistakes = [];
    for (var doc in snapshot.docs) {
      EditMistakeModel item = EditMistakeModel(
        acc_name: doc['ACC_name'],
        m_name: doc['M_name'],
        mm_time: doc['_time'],
        mm_subject: doc['_subject'],
        acc_id: '',
        m_id: '',
        mm_id: '',
        mm_month: '',
        std_id: '',
      );
      mistakes.add(item);
    }
    return mistakes;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Truy cập các tham số
    final studentID = args['studentID'];
    final studentName = args['studentName'];
    final monthKey = args['monthKey'] as int;
    final trainingScore = args['trainingScore'];
    final conduct = args['conduct'];

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
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          _buildStudentInfoRow('Họ và tên:', studentName),
                          _buildStudentInfoRow(
                              'Tháng:', Getmonthnow.getMonthName(monthKey)),
                          _buildStudentInfoRow(
                              'Điểm rèn luyện:', trainingScore.toString()),
                          _buildStudentInfoRow('Hạnh kiểm:', conduct),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.05,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.14,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(10),
                          topEnd: Radius.circular(10),
                        ),
                        color: Colors.blue.shade100,
                        border: Border.all(color: Colors.grey),
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
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'STT',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14),
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
                                      fontSize: 14),
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
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<EditMistakeModel>>(
                      future: getMistake(
                          studentID, Getmonthnow.getMonthName(monthKey)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SkeletonLoader(
                            builder: Column(
                              children: List.generate(
                                  3,
                                  (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      )),
                            ),
                            items: 1, // Số lượng skeleton items
                            period: const Duration(
                                seconds: 2), // Thời gian hiệu ứng
                          );
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Lỗi: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('Không có vi phạm nào.'));
                        }

                        listMistake = snapshot.data!;

                        return SingleChildScrollView(
                          child: Column(
                            children: listMistake.asMap().entries.map((entry) {
                              int index = entry.key;
                              var mistake = entry.value;

                              return StudentMistakeCard(
                                index: (index + 1).toString(),
                                mistake: mistake,
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
                    fontSize: 14),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(value,
                  style: TextStyle(color: Colors.black, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

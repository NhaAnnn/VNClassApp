import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_loader/skeleton_loader.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';

class ConductStudentMonth extends StatefulWidget {
  const ConductStudentMonth({
    super.key,
    this.studentDetailModel,
    this.monthKey,
    this.conduct,
    this.trainingScore,
  });
  static String routeName = 'conduct_student_month';
  final StudentDetailModel? studentDetailModel;
  final int? monthKey;
  final String? trainingScore;
  final String? conduct;
  @override
  State<ConductStudentMonth> createState() => _ConductStudentMonthState();
}

class _ConductStudentMonthState extends State<ConductStudentMonth> {
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
    final studentDetailModel = widget.studentDetailModel;

    final monthKey = widget.monthKey;
    final trainingScore = widget.trainingScore;
    final conduct = widget.conduct;

    if (studentDetailModel == null ||
        conduct == null ||
        trainingScore == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          BackBar(
            title: 'Hạnh kiểm của ${studentDetailModel.studentName}',
            backgroundColor: Colors.blue.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          Expanded(
            child: Column(
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
                        bottomRight: Radius.circular(10)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildStudentInfoRow(
                              'Họ và tên: ',
                              studentDetailModel.studentName.toString(),
                            ),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow(
                              'Lớp: ',
                              studentDetailModel.className.toString(),
                            ),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow(
                                'Tháng: ', Getmonthnow.getMonthName(monthKey!)),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow(
                                'Điểm rèn luyện: ', trainingScore.toString()),
                          ),
                          Expanded(
                            child: _buildStudentInfoRow(
                              'Hạnh kiểm: ',
                              conduct.toString(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildHeaderMistakeCard(),
                Expanded(
                  child: FutureBuilder<List<EditMistakeModel>>(
                    future: getMistake(studentDetailModel.id!,
                        Getmonthnow.getMonthName(monthKey)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SkeletonLoader(
                          builder: Column(
                            children: List.generate(
                                3,
                                (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    )),
                          ),
                          items: 1, // Số lượng skeleton items
                          period:
                              const Duration(seconds: 2), // Thời gian hiệu ứng
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Không có vi phạm nào.'));
                      }

                      listMistake = snapshot.data!;

                      return SingleChildScrollView(
                        child: Column(
                          children: listMistake.asMap().entries.map((entry) {
                            int index = entry.key;
                            var mistake = entry.value;

                            return _buildMistakeCard(
                                mistake,
                                (index + 1).toString(),
                                index == listMistake.length - 1);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                )
              ],
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
            Text(
              label,
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 81, 151),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMistakeCard(
      EditMistakeModel mistake, String index, bool isLastItem) {
    return Card(
      elevation: 4.0,
      color: Colors.white,
      margin: isLastItem
          ? const EdgeInsets.only(right: 15, left: 15, bottom: 15)
          : const EdgeInsets.only(right: 15, left: 15),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white, width: 1),
        borderRadius: isLastItem
            ? BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              )
            : BorderRadius.zero,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                index,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                mistake.m_name.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                mistake.acc_name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                mistake.mm_time,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMistakeCard() {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(top: 15.0, right: 15, left: 15),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.transparent, width: 1),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003B6F), Color.fromARGB(255, 0, 166, 255)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'STT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                'Tên Vi Phạm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Người cập nhật',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Thời gian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

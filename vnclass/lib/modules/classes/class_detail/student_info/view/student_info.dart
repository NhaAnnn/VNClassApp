import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/widget/send_notification_parent_dialog.dart';
import 'package:vnclass/modules/login/controller/provider.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});
  static String routeName = 'student_info';

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  StudentDetailModel? studentDetailModel; // Nullable
  StudentModel? studentModel; // Nullable

  Future<void> getStudent() async {
    studentModel = await StudentController.fetchStudentInfoByID(
        studentDetailModel!.studentID!);
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    if (accountProvider.account!.goupID.contains('hocSinh') ||
        accountProvider.account!.goupID.contains('phuHuynh')) {
      studentModel = args['studentModel'] as StudentModel;
    } else {
      studentDetailModel = args['studentDetailModel'] as StudentDetailModel?;
      getStudent();
    }

    double paddingValue = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const BackBar(title: 'Thông tin học sinh'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(paddingValue),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: paddingValue),
                      child: const Text(
                        'Thông tin học sinh:',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: paddingValue * 0.5),
                    if (studentModel != null) ...[
                      _buildStudentDetailRow(
                          'Mã học sinh:', studentModel!.id.toString()),
                      _buildStudentDetailRow(
                          'Họ và tên:', studentModel!.studentName ?? 'N/A'),
                      _buildStudentDetailRow(
                          'Giới tính:', studentModel!.gender ?? 'N/A'),
                      _buildStudentDetailRow(
                          'Ngày sinh:', studentModel!.birthday ?? 'N/A'),
                    ] else if (studentDetailModel != null) ...[
                      _buildStudentDetailRow(
                          'Mã học sinh:', studentDetailModel!.id.toString()),
                      _buildStudentDetailRow(
                          'Lớp học:', args['className'] ?? 'N/A'),
                      _buildStudentDetailRow('Họ và tên:',
                          studentDetailModel!.studentName ?? 'N/A'),
                      _buildStudentDetailRow(
                          'Giới tính:', studentDetailModel!.gender ?? 'N/A'),
                      _buildStudentDetailRow(
                          'Ngày sinh:', studentDetailModel!.birthday ?? 'N/A'),
                    ],
                    if (accountProvider.account!.goupID
                        .contains('giaoVien')) ...[
                      Padding(
                        padding: EdgeInsets.all(paddingValue),
                        child: const Text(
                          'Chức vụ:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: RadioListTile(
                              title: const Text('Học sinh',
                                  style: TextStyle(fontSize: 16)),
                              value: 'Học sinh',
                              groupValue: studentDetailModel?.committee,
                              onChanged: (value) {
                                setState(() {
                                  studentDetailModel?.committee = value!;
                                });
                              },
                              activeColor: Colors.blueAccent,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              title: const Text('Ban cán sự',
                                  style: TextStyle(fontSize: 16)),
                              value: 'Ban cán sự',
                              groupValue: studentDetailModel?.committee,
                              onChanged: (value) {
                                setState(() {
                                  studentDetailModel?.committee = value!;
                                });
                              },
                              activeColor: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: paddingValue), // Space between buttons
                      Center(
                        child: ButtonN(
                          color: Colors.blueAccent,
                          ontap: () {
                            if (studentDetailModel != null) {
                              StudentDetailController
                                  .updateStudentPositionInDatabase(
                                      context, studentDetailModel!);
                            }
                          },
                          label: 'Cập nhật chức vụ',
                          colorText: Colors.white,
                        ),
                      ),
                      SizedBox(
                          height: paddingValue * 0.5), // Space between buttons
                      Center(
                        child: ButtonN(
                          color: Colors.blueAccent,
                          ontap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return SendNotificationParentDialog(
                                    pID: studentModel!.pID!,
                                  );
                                });
                          },
                          label: 'Gửi thông báo cho phụ huynh',
                          colorText: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDetailRow(String label, String value) {
    return Card(
      elevation: 4, // Increased elevation for better shadow effect
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 4), // Space between cards
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

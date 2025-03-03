import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});
  static String routeName = 'student_info';

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Lấy dữ liệu từ arguments
    final StudentModel studentModel = args['studentModel'] as StudentModel;
    final String className = args['className'] as String;
    double paddingValue = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: '12a1',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(paddingValue * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: paddingValue * 0.02, left: paddingValue * 0.02),
                    child: Text(
                      'Thông tin học sinh:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: paddingValue * 0.16),
                  _buildStudentDetailRow(
                      'Mã học sinh:', studentModel.id.toString()),
                  _buildStudentDetailRow('Lớp học:', className),
                  _buildStudentDetailRow(
                      'Họ và tên:', studentModel.studentName.toString()),
                  _buildStudentDetailRow(
                      'Giới tính:', studentModel.gender.toString()),
                  _buildStudentDetailRow(
                      'Ngày sinh:', studentModel.birthday.toString()),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(paddingValue * 0.03),
                        child: Text('Chức vụ:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      Radio(
                        value: 'Học sinh',
                        groupValue: studentModel.committee.toString(),
                        onChanged: (value) {
                          setState(() {
                            studentModel.committee = value; // Cập nhật chức vụ
                          });
                        },
                        activeColor: Colors.blueAccent,
                      ),
                      Text('Học sinh', style: TextStyle(fontSize: 18)),
                      Radio(
                        value: 'Ban cán sự',
                        groupValue: studentModel.committee.toString(),
                        onChanged: (value) {
                          setState(() {
                            studentModel.committee = value; // Cập nhật chức vụ
                          });
                        },
                        activeColor: Colors.blueAccent,
                      ),
                      Text('Ban cán sự', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
                  ButtonN(
                    color: Colors.blueAccent,
                    size: Size(MediaQuery.sizeOf(context).width * 0.4,
                        MediaQuery.sizeOf(context).height * 0.05),
                    ontap: () {
                      StudentDetailController.updateStudentPositionInDatabase(
                          context, studentModel);
                    },
                    label: 'Cập nhật',
                    colorText: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDetailRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

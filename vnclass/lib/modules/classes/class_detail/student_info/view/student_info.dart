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
    double paddingValue = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: 'Thông tin học sinh',
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(paddingValue),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: paddingValue),
                      child: Text(
                        'Thông tin học sinh:',
                        style: TextStyle(
                          fontSize: 26, // Increased font size for visibility
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: paddingValue * 0.5),
                    _buildStudentDetailRow(
                        'Mã học sinh:', studentModel.id.toString()),
                    _buildStudentDetailRow('Lớp học:', className),
                    _buildStudentDetailRow(
                        'Họ và tên:', studentModel.studentName!),
                    _buildStudentDetailRow('Giới tính:', studentModel.gender!),
                    _buildStudentDetailRow(
                        'Ngày sinh:', studentModel.birthday!),
                    Padding(
                      padding: EdgeInsets.all(paddingValue),
                      child: Text('Chức vụ:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: Text('Học sinh',
                                style: TextStyle(fontSize: 16)),
                            value: 'Học sinh',
                            groupValue: studentModel.committee,
                            onChanged: (value) {
                              setState(() {
                                studentModel.committee = value!;
                              });
                            },
                            activeColor: Colors.blueAccent,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: Text('Ban cán sự',
                                style: TextStyle(fontSize: 16)),
                            value: 'Ban cán sự',
                            groupValue: studentModel.committee,
                            onChanged: (value) {
                              setState(() {
                                studentModel.committee = value!;
                              });
                            },
                            activeColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: paddingValue),
                    Center(
                      child: ButtonN(
                        color: Colors.blueAccent,
                        size: Size(MediaQuery.of(context).size.width * 0.4,
                            MediaQuery.of(context).size.height * 0.05),
                        ontap: () {
                          StudentDetailController
                              .updateStudentPositionInDatabase(
                                  context, studentModel);
                        },
                        label: 'Cập nhật',
                        colorText: Colors.white,
                      ),
                    ),
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
      elevation: 1,
      color: Colors.white, // Add elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      // margin: EdgeInsets.symmetric(vertical: 8),
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
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: TextStyle(
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

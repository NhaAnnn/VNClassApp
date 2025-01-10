import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});
  static String routeName = 'student_info';

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  // final ClassModel classModel;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Lấy arguments từ ModalRoute
  //   final args = ModalRoute.of(context)!.settings.arguments as StudentModel;
  //    // Lấy arguments từ ModalRoute
  //   final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

  //   // Lấy đối tượng StudentModel và ClassModel
  //   final StudentModel studentModel = args['student'] as StudentModel;
  //   final ClassModel classModel = args['class'] as ClassModel;
  //   studentModel = args; // Gán giá trị cho classID
  // }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Lấy dữ liệu từ arguments
    final StudentModel studentModel = args['studentModel'] as StudentModel;
    final String className = args['className'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: '12a1',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 20),
                    child: Text(
                      'Thông tin học sinh:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStudentDetailRow(
                      'Mã học sinh:', studentModel.id.toString()),
                  _buildStudentDetailRow('Lớp học:', className),
                  _buildStudentDetailRow('Họ và tên:',
                      studentModel.studentInfoModel.studentName.toString()),
                  _buildStudentDetailRow('Giới tính:',
                      studentModel.studentInfoModel.gender.toString()),
                  _buildStudentDetailRow('Ngày sinh:',
                      studentModel.studentInfoModel.birthday.toString()),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
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
                  SizedBox(height: 20),
                  ButtonN(
                    ontap: () {
                      StudentController.updateStudentPositionInDatabase(
                          studentModel); // Gọi hàm cập nhật khi nhấn nút
                    },
                    label: 'Cập nhật',
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
        padding: const EdgeInsets.all(12.0),
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

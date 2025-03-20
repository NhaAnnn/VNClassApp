import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/classes/class_detail/controller/class_controller.dart';
import 'package:vnclass/modules/classes/class_detail/model/class_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/controller/student_detail_controller.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/widget/send_notification_parent_dialog.dart';
import 'package:vnclass/modules/login/controller/provider.dart';

import '../../../common/widget/drop_menu_widget.dart';

class StudentWidget extends StatefulWidget {
  const StudentWidget({super.key, required this.classModel});
  final ClassModel classModel;

  @override
  State<StudentWidget> createState() => _StudentWidgetState();
}

class _StudentWidgetState extends State<StudentWidget> {
  List<StudentDetailModel> students = [];
  StudentModel? studentModel;

  // Sample Committees (replace it with your real data)
  List<String> committees = ['Học sinh', 'Ban cán sự'];

  Future<void> _loadStudentDetail() async {
    var fetchedStudents = await StudentDetailController.fetchStudentsByClass(
        widget.classModel.id!);
    setState(() {
      students = fetchedStudents;
    });
  }

  Future<void> getStudent(String studentID) async {
    studentModel = await StudentController.fetchStudentInfoByID(studentID);
  }

  @override
  void initState() {
    super.initState();
    _loadStudentDetail();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Thông tin học sinh', style: TextStyle(fontSize: 18)),
          SizedBox(height: 20),
          Text('Lớp: ${widget.classModel.className}',
              style: TextStyle(fontSize: 18)),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: <DataColumn>[
                  DataColumn(label: Center(child: Text('Mã'))),
                  DataColumn(label: Text('Tên')),
                  DataColumn(label: Text('Ngày sinh')),
                  DataColumn(label: Text('Giới tính')),
                  DataColumn(label: Center(child: Text('Chức vụ'))),
                  if (accountProvider.account!.goupID.contains('giaoVien')) ...[
                    DataColumn(label: Center(child: Text('Thông báo'))),
                  ]
                ],
                rows: students.isNotEmpty
                    ? students.map((student) {
                        getStudent(student.studentID!);
                        return DataRow(cells: <DataCell>[
                          DataCell(Text(student.studentID!)),
                          DataCell(Text(student.studentName!)),
                          DataCell(
                              Center(child: Text(student.birthday.toString()))),
                          DataCell(
                              Center(child: Text(student.gender.toString()))),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: DropMenuWidget(
                                items: committees,
                                hintText: student.committee,
                                borderColor: Colors.white,
                                hintColor: Colors.black,
                                textStyle: TextStyle(
                                    fontSize: 14, color: Colors.black),
                                onChanged: (value) {
                                  setState(() {
                                    student.committee = value;
                                    StudentDetailController
                                        .updateStudentPositionInDatabase(
                                            context, student);
                                  });
                                },
                              ),
                            ),
                          ),
                          if (accountProvider.account!.goupID
                              .contains('giaoVien')) ...[
                            DataCell(
                              Center(
                                child: Tooltip(
                                  message:
                                      'Gửi thông báo đến phụ huynh', // Your tooltip message
                                  child: ButtonN(
                                    label: 'Phụ huynh',
                                    colorText: Colors.white,
                                    color: Colors.blueAccent,
                                    size: Size(100, 40),
                                    ontap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          print(studentModel!.pID!);
                                          return SendNotificationParentDialog(
                                            pID: studentModel!.pID!,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ]);
                      }).toList()
                    : [
                        DataRow(cells: <DataCell>[
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('Đang tải dữ liệu')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ]),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

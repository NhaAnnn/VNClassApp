import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vnclass/common/widget/back_bar.dart';
import 'package:vnclass/common/widget/button_n.dart';
import 'package:vnclass/modules/account/model/account_edit_model.dart';
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
                    if (studentDetailModel != null) ...[
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
                    ] else if (studentModel != null) ...[
                      _buildStudentDetailRow(
                          'Mã học sinh:', studentModel!.id.toString()),
                      _buildStudentDetailRow(
                          'Họ và tên:', studentModel!.studentName ?? 'N/A'),
                      _buildStudentDetailRow(
                          'Giới tính:', studentModel!.gender ?? 'N/A'),
                      _buildStudentDetailRow(
                          'Ngày sinh:', studentModel!.birthday ?? 'N/A'),
                    ],
                    if (accountProvider.account!.goupID
                        .contains('giaoVien')) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Chức vụ',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.grey.shade400, // Border color
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color:
                                          Colors.grey.shade400, // Border color
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors
                                          .blueAccent, // Focused border color
                                    ),
                                  ),
                                ),
                                dropdownColor: Colors
                                    .white, // Dropdown menu background color
                                value: studentDetailModel?.committee,
                                items: ['Học sinh', 'Ban cán sự']
                                    .map((position) => DropdownMenuItem<String>(
                                          value: position,
                                          child: Text(
                                            position,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black, // Text color
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) async {
                                  setState(() {
                                    studentDetailModel?.committee = value!;
                                  });
                                  if (studentDetailModel != null) {
                                    StudentDetailController
                                        .updateStudentPositionInDatabase(
                                            context, studentDetailModel!);
                                  }
                                  final stuAccID =
                                      await StudentController.fetchAccountByID(
                                          studentDetailModel!.studentID!);
                                  print('object $stuAccID');
                                  try {
                                    CollectionReference accounts =
                                        FirebaseFirestore.instance
                                            .collection('ACCOUNT');
                                    QuerySnapshot querySnapshot = await accounts
                                        .where('_id',
                                            isEqualTo: stuAccID.toString())
                                        .get();
                                    if (querySnapshot.docs.isNotEmpty) {
                                      DocumentSnapshot document =
                                          querySnapshot.docs.first;
                                      List<dynamic> permissions =
                                          document.get('_permission') ?? [];
                                      if (value == 'Ban cán sự') {
                                        if (!permissions.contains(
                                            'Cập nhật vi phạm lớp học')) {
                                          permissions
                                              .add('Cập nhật vi phạm lớp học');
                                        }
                                        await accounts.doc(document.id).update(
                                            {'_permission': permissions});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Lưu thay đổi quyền thành công!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else if (value == 'Học sinh') {
                                        permissions
                                            .remove('Cập nhật vi phạm lớp học');
                                        await accounts.doc(document.id).update(
                                            {'_permission': permissions});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Xóa quyền thành công!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Không tìm thấy tài khoản!'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    print('Lỗi khi lưu permissions: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Lưu thay đổi thất bại!'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: paddingValue * 0.5), // Space between buttons
                      Center(
                        child: SizedBox(
                          width: double.infinity, // Full width button
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SendNotificationParentDialog(
                                      pID: studentModel!.pID!,
                                    );
                                  });
                            },
                            child: const Text(
                              'Gửi thông báo cho phụ huynh',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
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

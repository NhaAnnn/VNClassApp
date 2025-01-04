import 'package:flutter/material.dart';
import 'package:vnclass/common/widget/back_bar.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});
  static String routeName = 'student_info';

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedPosition = 'Ban cán sự';

  void onChanged(String? value) {
    setState(() {
      _selectedPosition = value; // Update the state variable
    });
    // Call function to update database
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildStudentDetailRow('Mã học sinh:', '123456'),
                  _buildStudentDetailRow('Lớp học:', '123456'),
                  _buildStudentDetailRow(
                      'Họ và tên:', '1234dsgdsfgdfsgsdfgdfsgdfgsdfgsdf56'),
                  _buildStudentDetailRow('Giới tính:', 'NAMNAM'),
                  _buildStudentDetailRow('Ngày sinh:', '12/34/555556'),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Chức vụ:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      Radio(
                        value: 'Học sinh',
                        groupValue: _selectedPosition,
                        onChanged: onChanged,
                        activeColor: Colors.blueAccent,
                      ),
                      Text(
                        'Học sinh',
                        style: TextStyle(fontSize: 18),
                      ),
                      Radio(
                        value: 'Ban cán sự',
                        groupValue: _selectedPosition,
                        onChanged: onChanged,
                        activeColor: Colors.blueAccent,
                      ),
                      Text(
                        'Ban cán sự',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
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

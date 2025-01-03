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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          BackBar(
            title: '12a1',
          ),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin học sinh:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Lớp:',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

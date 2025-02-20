import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/view/student_info.dart';

class ClassDetailCard extends StatefulWidget {
  const ClassDetailCard({
    super.key,
    required this.studentModel,
    this.className,
  });

  final StudentModel studentModel;
  final String? className;
  @override
  State<ClassDetailCard> createState() => _ClassDetailCardState();
}

class _ClassDetailCardState extends State<ClassDetailCard> {
  StudentModel get studentModel => widget.studentModel;
  String? get className => widget.className;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildClassDetailRow(
                      'Mã học sinh:', studentModel.id.toString()),
                  _buildClassDetailRow(
                      'Họ và tên:', studentModel.studentName.toString()),
                  _buildClassDetailRow(
                      'Chức vụ:', studentModel.committee.toString()),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context)
                    .pushNamed(StudentInfo.routeName, arguments: {
                  'studentModel': studentModel,
                  'className': className,
                }),
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  FontAwesomeIcons.angleRight,
                  size: 36,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDetailRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                value,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

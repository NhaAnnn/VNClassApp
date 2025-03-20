import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/model/student_detail_model.dart';
import 'package:vnclass/modules/classes/class_detail/student_info/view/student_info.dart';

class ClassDetailCard extends StatefulWidget {
  const ClassDetailCard({
    super.key,
    required this.studentDetailModel,
    this.className,
  });

  final StudentDetailModel studentDetailModel;
  final String? className;
  @override
  State<ClassDetailCard> createState() => _ClassDetailCardState();
}

class _ClassDetailCardState extends State<ClassDetailCard> {
  StudentDetailModel get studentDetailModel => widget.studentDetailModel;
  String? get className => widget.className;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blueAccent, width: 1),
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
                      'Mã học sinh:', studentDetailModel.id.toString()),
                  _buildClassDetailRow(
                      'Họ và tên:', studentDetailModel.studentName.toString()),
                  _buildClassDetailRow(
                      'Chức vụ:', studentDetailModel.committee.toString()),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context)
                    .pushNamed(StudentInfo.routeName, arguments: {
                  'studentDetailModel': studentDetailModel,
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

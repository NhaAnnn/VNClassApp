import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/button_add.dart';
import 'package:vnclass/modules/class_detail/view/class_detail.dart';
import 'package:vnclass/modules/student_info/view/student_info.dart';

class ClassDetailCard extends StatefulWidget {
  const ClassDetailCard({super.key});

  @override
  State<ClassDetailCard> createState() => _ClassDetailCardState();
}

class _ClassDetailCardState extends State<ClassDetailCard> {
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
                  _buildClassDetailRow('Mã học sinh:', '13231323'),
                  _buildClassDetailRow('STT:', '13231323'),
                  _buildClassDetailRow('Họ và tên:', '13231323'),
                  _buildClassDetailRow('Chức vụ:', '13231323'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context).pushNamed(StudentInfo.routeName),
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

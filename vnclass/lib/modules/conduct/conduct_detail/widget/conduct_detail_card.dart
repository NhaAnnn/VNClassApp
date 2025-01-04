import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/view/student_conduct_info.dart';

class ConductDetailCard extends StatelessWidget {
  const ConductDetailCard({super.key});

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
                  _buildClassDetailRow('Họ và tên:', '13231323'),
                  _buildClassDetailRow('Điểm rèn luyện:', '13231323'),
                  _buildClassDetailRow('Hạnh kiểm:', 'vlsdfdsgvlsdfdsg')
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {
                Navigator.of(context).pushNamed(StudentConductInfo.routeName),
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
        padding: const EdgeInsets.all(8.0),
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

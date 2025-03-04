import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/funtion/getMonthNow.dart';
import 'package:vnclass/modules/conduct/conduct_detail/student_conduct_info/view/student_conduct_info_month.dart';

class StudentConductMonthCard extends StatefulWidget {
  const StudentConductMonthCard({
    super.key,
    this.studentID,
    this.studentName,
    this.month,
    this.conduct,
    this.trainingScore,
  });

  final String? studentID;
  final String? studentName;
  final String? month;
  final String? trainingScore;
  final String? conduct;

  @override
  State<StudentConductMonthCard> createState() =>
      _StudentConductMonthCardState();
}

class _StudentConductMonthCardState extends State<StudentConductMonthCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.month ?? 'Tháng không xác định',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 12), // Khoảng cách giữa các dòng

                  _buildInfoRow(
                      'Điểm rèn luyện:', widget.trainingScore ?? 'N/A'),
                  _buildInfoRow('Hạnh kiểm:', widget.conduct ?? 'N/A'),
                  SizedBox(height: 12), // Khoảng cách giữa các dòng
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  StudentConductInfoMonth.routeName,
                  arguments: {
                    'studentID': widget.studentID,
                    'studentName': widget.studentName,
                    'monthKey': Getmonthnow.getMonthNumber(widget.month!),
                    'trainingScore': widget.trainingScore,
                    'conduct': widget.conduct,
                  },
                );
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  FontAwesomeIcons.angleRight,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

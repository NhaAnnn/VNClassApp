import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/modules/mistake/models/edit_mistake_model.dart';

class StudentMistakeCard extends StatefulWidget {
  const StudentMistakeCard({super.key, this.mistake, this.index});

  final EditMistakeModel? mistake;
  final String? index;
  @override
  State<StudentMistakeCard> createState() => _StudentMistakeCardState();
}

class _StudentMistakeCardState extends State<StudentMistakeCard> {
  bool _isVisible = false;
  bool _isRotated = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      // elevation: 8,
      margin: EdgeInsetsDirectional.only(bottom: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(
            color: const Color.fromARGB(255, 207, 206, 206), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(widget.index!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Expanded(
                        flex: 8,
                        child: Text(widget.mistake!.m_name.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // Space between rows
                  if (_isVisible)
                    _buildMistakeDetailRow(
                        widget.mistake!.acc_name, widget.mistake!.mm_time)
                ],
              ),
            ),
            GestureDetector(
              onTap: () => {
                setState(() {
                  _isRotated = !_isRotated;
                  _isVisible = !_isVisible;
                }),
              },
              child: Transform.rotate(
                angle: _isRotated ? 3.14 : 0,
                child: Icon(
                  FontAwesomeIcons.angleDown,
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

  Widget _buildMistakeDetailRow(String name, String time) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(
                    'Được cập nhật bởi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Expanded(flex: 7, child: Text(name)),
            ],
          ),
          SizedBox(height: 8), // Space between rows
          Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(
                    'Thời gian:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Expanded(flex: 7, child: Text(time)),
            ],
          ),
          SizedBox(height: 8), //
        ],
      ),
    );
  }
}

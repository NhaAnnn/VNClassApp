import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentMistakeCard extends StatefulWidget {
  const StudentMistakeCard({super.key});

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
                        child: Text('1',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Expanded(
                        flex: 8,
                        child: Text('Column 2hhfghhghhghhghgh',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 16)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12), // Space between rows
                  if (_isVisible)
                    _buildMistakeDetailRow('asdgdhgfd', 'fssfsd 12/15/5155')
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

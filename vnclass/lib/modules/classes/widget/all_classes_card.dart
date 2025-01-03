import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vnclass/common/widget/button_add.dart';
import 'package:vnclass/modules/class_detail/view/class_detail.dart';

class AllClassesCard extends StatefulWidget {
  const AllClassesCard({super.key});

  @override
  State<AllClassesCard> createState() => _AllClassesCardState();
}

class _AllClassesCardState extends State<AllClassesCard> {
  bool _isVisible = false;
  bool _isRotated = false;

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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildClassRow('Lớp:', '12a1'),
                  _buildClassRow('Sỉ số:', 'value'),
                  _buildClassRow('GVCN', 'value'),
                  if (_isVisible) _buildControlRow(),
                ],
              ),
            ),
            GestureDetector(
              child: Transform.rotate(
                angle: _isRotated ? 3.14 : 0,
                child: Icon(
                  FontAwesomeIcons.angleDown,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              onTap: () => {
                setState(() {
                  _isRotated = !_isRotated;
                  _isVisible = !_isVisible;
                }),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassRow(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 7,
              child: Text(value, style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Avoid infinite width
      children: [
        Icon(icon, color: color),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildControlRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            child: _buildControlButton(
                'Xem', FontAwesomeIcons.solidEye, Colors.black),
            onTap: () => {
              Navigator.of(context).pushNamed(ClassDetail.routeName),
            },
          ),
          _buildControlButton(
              'Sửa', FontAwesomeIcons.pencil, Colors.blueAccent),
          _buildControlButton(
              'Xóa', FontAwesomeIcons.solidTrashCan, Colors.redAccent)
        ],
      ),
    );
  }
}
